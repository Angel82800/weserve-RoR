require 'rails_helper'

RSpec.describe TasksController do
  let(:user) do
    user = create(:user, :confirmed_user, username: 'taskuser')
  end

  let(:admin) do
    admin = create(:user, :confirmed_user, username: 'admin', admin: true)
  end

  let(:project) do
    FactoryGirl.create(:project, user: user)
  end

  before do
    sign_in(admin)
  end

  describe '#create' do
    before { post(:create, create_params) }

    context 'with valid parameters' do
      let(:create_params) do
        { task: {
          title: 'title', budget: 10000, target_number_of_participants: 1,
          condition_of_execution: 'condition',
          proof_of_execution: 'A proof of execution',
          deadline: Time.now, project_id: project.id
        } }
      end

      it { is_expected.to redirect_to(taskstab_project_path(project, tab: 'tasks')) }
      it { expect(flash[:notice]).to eq(I18n.t('tasks.create.notice_message')) }
    end

    context 'with invalid parameters' do
      let(:create_params) { { task: { title: '', project_id: project.id } } }

      it { is_expected.to redirect_to(taskstab_project_path(project, tab: 'tasks')) }
      it { expect(flash[:alert]).to eq(I18n.t('tasks.create.alert_message')) }
    end
  end

  describe '#update' do
    let(:existing_task) do
      create(:task, :with_associations, :with_balance, project: project, user: user)
    end

    let(:update_params) do
      {
        title: 'Updated title',
        short_description: 'Updated short description',
        condition_of_execution: 'Updated condition of execution',
        proof_of_execution: 'Updated proof of execution',
        deadline: '2017-02-21 01:46 PM'
      }
    end

    it 'updates existing task' do
      patch(:update, id: existing_task.id, task: update_params)

      updated_task = Task.find(existing_task.id)

      update_params.each do |key, value|
        expect(updated_task.send(key)).to eq(value)
      end
    end

    it 'ignores deadline attribute for task with any funding' do
      existing_task.update_current_fund!(2000)

      expect do
        patch(:update, id: existing_task.id, task: update_params)
      end.not_to change { Task.find(existing_task.id).deadline }
    end

    context 'with invalid parameters' do
      let(:update_params) { { title: '' } }

      it 'returns unprocessable entity status' do
        patch(:update, id: existing_task.id, task: update_params)
        expect(response.status).to eq 422
      end
    end
  end

  describe '#reviewing' do
    subject(:make_request) { get(:reviewing, id: existing_task.id) }

    context 'when the task is eligible to move to under review' do
      let(:existing_task) do
        FactoryGirl.create(
          :task,
          :with_balance,
          project: project,
          user: user,
          state: 'doing',
          current_fund: 3000.0,
          budget: 3000.0,
          number_of_participants: 1,
          target_number_of_participants: 1
        )
      end
      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
      let(:only_follower) { FactoryGirl.create(:user, :confirmed_user) }
      let(:follower_and_member) { FactoryGirl.create(:user, :confirmed_user) }
      let(:task_user) { FactoryGirl.create(:user, :confirmed_user) }

      before do
        project_team = project.create_team(name: "Team#{project.id}")
        team_membership = TeamMembership.create!(team_member: user, team_id: project_team.id, role: 1)
        TeamMembership.create!(team_member: follower_and_member, team_id: project_team.id, role: 0)
        team_membership.tasks << existing_task
        team_membership.save!

        project.followers << only_follower
        project.followers << follower_and_member
        project.save!

        TaskMember.create(task_id: existing_task.id, team_membership_id: team_membership.id)
        existing_task.save!

        allow(NotificationMailer).to receive(:under_review_task).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
        allow_any_instance_of(User).to receive(:can_submit_task?).with(existing_task).and_return(true)
      end

      it 'task goes in state of doing' do
        expect { make_request }.to change { existing_task.reload.state }.from('doing').to('reviewing')
      end

      it 'redirects to project taskstab path' do
        make_request

        expect(response).to redirect_to(taskstab_project_url(existing_task.project, tab: 'tasks'))
      end

      it 'flashes the correct message' do
        make_request

        expect(flash[:notice]).to eq(I18n.t('tasks.reviewing.task_submitted'))
      end

      it 'sends an email to the involved users', :aggregate_failures do
        expect(NotificationMailer).to receive(:under_review_task).exactly(1).times
        expect(message_delivery).to receive(:deliver_later).exactly(1).times

        make_request
      end
    end
  end

  describe '#destroy' do
    let(:task) { FactoryGirl.create(:task, :with_associations) }
    let(:user) { task.user }
    let(:project) { task.project }

    context 'given user is authorized' do
      before do
        allow_any_instance_of(described_class).to receive(:authorize!).and_return(true)
      end

      context 'when task delete service returns true' do
        before do
          allow_any_instance_of(TaskDestroyService).to receive(:destroy_task).and_return(true)
        end

        it 'returns user to tasks page with successful message' do
          delete(:destroy, id: task.id)

          expect(flash[:notice]).to eq(I18n.t('tasks.destroy.notice_message'))
          expect(response).to redirect_to(
            taskstab_project_path(project, tab: 'tasks')
          )
        end
      end

      context 'when task delete service returns false' do
        before do
          allow_any_instance_of(TaskDestroyService).to receive(:destroy_task).and_return(false)
        end

        it 'returns user to tasks page with unsuccessful message' do
          delete(:destroy, id: task.id)

          expect(flash[:error]).to eq(I18n.t('tasks.destroy.error_message'))
          expect(response).to redirect_to(
            taskstab_project_path(project, tab: 'tasks')
          )
        end
      end

      context 'when task delete service returns general error' do
        before do
          allow_any_instance_of(TaskDestroyService).to receive(:destroy_task) do
            raise Payments::BTC::Errors::GeneralError, 'Coinbase API error'
          end
        end

        it 'returns user to tasks page with unsuccessful message' do
          delete(:destroy, id: task.id)

          expect(flash[:error]).to eq(I18n.t('commons.connecting_payment_service_error'))
          expect(response).to redirect_to(
            taskstab_project_path(project, tab: 'tasks')
          )
        end
      end
    end
  end

  describe '#remove_member' do
    let(:task)            { create(:task, :suggested, project: project) }
    let(:team_membership) { create(:team_membership, :task, task: task) }

    context 'reason given' do
      before do
        delete :remove_member, id: task.id, team_membership_id: team_membership.id, reason: 'need new member', format: :json
      end

      it 'removes success' do
        expect(response.status).to eq(200)
      end

      it 'creates an activity' do
        expect(Activity.count).to eq 1
      end
    end

    context 'no reason given' do
      before do
        delete :remove_member, id: task.id, team_membership_id: team_membership.id, format: :json
      end

      it "doesn't remove member" do
        expect(response.status).to eq(422)
      end
    end
  end

  describe '#completed' do
    before do
      allow_any_instance_of(Task).to receive(:update_current_fund!).and_return(true)
      project_team = project.create_team(name: "Team#{project.id}")
      TeamMembership.create!(team_member: user, team_id: project_team.id, role: 1)
      TeamMembership.create!(team_member: follower_and_member, team_id: project_team.id, role: 0)

      project.followers << only_follower
      project.followers << follower_and_member
      project.save!

      allow(NotificationMailer).to receive(:task_completed).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)
    end

    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
    let(:only_follower) { FactoryGirl.create(:user, :confirmed_user) }
    let(:follower_and_member) { FactoryGirl.create(:user, :confirmed_user) }

    let(:task_params) do
      {
        state: :reviewing,
        project: project,
        user: user,
        current_fund: 2000,
        budget: 2000
      }
    end
    let(:existing_task) do
      FactoryGirl.create(:task, :with_associations, :with_balance, task_params)
    end

    it 'performs successful task completion' do
      allow_any_instance_of(TaskCompleteService).to receive(:complete!).and_return(true)
      get :completed, id: existing_task.id

      expect(assigns(:notice)).to eq(I18n.t('tasks.completed.task_completed'))
    end

    it 'performs not successful task completion' do
      allow_any_instance_of(TaskCompleteService).to receive(:complete!).and_raise(
        Payments::BTC::Errors::TransferError, I18n.t('commons.some_error')
      )
      get :completed, id: existing_task.id

      expect(assigns(:notice)).to eq(I18n.t('commons.some_error'))
    end

    it 'sends an email to the involved users', :aggregate_failures do
      allow_any_instance_of(TaskCompleteService).to receive(:complete!).and_return(true)
      expect(NotificationMailer).to receive(:task_completed).exactly(1).times
      expect(message_delivery).to receive(:deliver_later).exactly(1).times

      get :completed, id: existing_task.id
    end
  end

  describe '#accept' do
    subject(:make_request) { get(:accept, id: existing_task.id) }

    context 'when the task is accepted successful' do
      let(:existing_task) do
        FactoryGirl.create(:task, :with_associations, project: project, user: task_user, state: 'suggested_task')
      end
      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
      let(:only_follower) { FactoryGirl.create(:user, :confirmed_user) }
      let(:follower_and_member) { FactoryGirl.create(:user, :confirmed_user) }
      let(:task_user) { FactoryGirl.create(:user, :confirmed_user) }

      before do
        project_team = project.create_team(name: "Team#{project.id}")
        TeamMembership.create!(team_member: follower_and_member, team_id: project_team.id, role: 0)

        project.followers << only_follower
        project.followers << follower_and_member
        project.save!

        allow(NotificationMailer).to receive(:accept_new_task).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
      end

      it 'accepts the task' do
        expect(existing_task.suggested_task?).to be true
        expect(existing_task.accepted?).to be false

        make_request

        updated_task = Task.find(existing_task.id)
        expect(updated_task.suggested_task?).to be false
        expect(updated_task.accepted?).to be true
      end

      it 'redirects to project taskstab path' do
        make_request

        expect(response).to redirect_to(taskstab_project_url(existing_task.project, tab: 'tasks'))
      end

      it 'flashes the correct message' do
        make_request

        expect(flash[:notice]).to eq(I18n.t('tasks.accept.task_accepted'))
      end

      it 'sends an email to the involved users', :aggregate_failures do
        expect(NotificationMailer).to receive(:accept_new_task).exactly(2).times
        expect(message_delivery).to receive(:deliver_later).exactly(2).times

        make_request
      end
    end
  end

  describe '#reject task' do
    subject(:make_request) { get(:reject, id: existing_task.id) }
    context 'when the task is rejected back into Suggested' do
      let(:existing_task) do
        FactoryGirl.create(:task, :with_associations, project: project, user: task_user, state: 'accepted')
      end

      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
      let(:only_follower) { FactoryGirl.create(:user, :confirmed_user) }
      let(:follower_and_member) { FactoryGirl.create(:user, :confirmed_user) }
      let(:task_user) { FactoryGirl.create(:user, :confirmed_user) }

      before do
        project_team = project.create_team(name: "Team#{project.id}")
        TeamMembership.create!(team_member: follower_and_member, team_id: project_team.id, role: 0)

        project.followers << only_follower
        project.followers << follower_and_member
        project.save!

        allow(NotificationMailer).to receive(:reject_task_to_suggested).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
      end

      context '# cannot reject task' do
        # You are not authorized to access this page.
        before do
          balance = existing_task.balance.update_attribute(:funded, 2000)
        end

        it 'rejected the task' do
          expect(existing_task.accepted?).to be true
          expect(existing_task.suggested_task?).to be false
          expect(existing_task.current_fund).not_to eq(0.0)
          make_request
          updated_task = Task.find(existing_task.id)
          expect(updated_task.suggested_task?).to be false
          expect(updated_task.accepted?).to be true
        end
        it 'redirects to project taskstab path' do
          make_request

          expect(response).to redirect_to(root_url)
        end

        it 'flashes the correct message' do
          make_request

          expect(flash[:notice]).to eq(I18n.t('commons.unauthorized_access'))
        end
      end

      it 'rejected the task' do
        expect(existing_task.accepted?).to be true
        expect(existing_task.suggested_task?).to be false
        expect(existing_task.current_fund).to eq(0.0)
        make_request

        updated_task = Task.find(existing_task.id)
        expect(updated_task.suggested_task?).to be true
        expect(updated_task.accepted?).to be false
      end

      it 'redirects to project taskstab path' do
        make_request

        expect(response).to redirect_to(taskstab_project_url(existing_task.project, tab: 'tasks'))
      end

      it 'flashes the correct message' do
        make_request

        expect(flash[:notice]).to eq(I18n.t('tasks.reject.task_rejected', task_title: existing_task.title))
      end

      it 'sends an email to the involved users', :aggregate_failures do
        expect(NotificationMailer).to receive(:reject_task_to_suggested).exactly(2).times
        expect(message_delivery).to receive(:deliver_later).exactly(2).times

        make_request
      end
    end

  end

  describe '#task_fund_info' do
    let(:task) { create(:task) }

    it 'returns a successful response' do
      xhr :get, :task_fund_info, id: task.id, format: :json
      expect(response.status).to eq(200)
    end
  end

  describe '#show', vcr: { cassette_name: 'tasks_controller/show',
                           match_requests_on: [:path, :query] } do
    let(:task) { create(:task, :suggested, project: project, board_id: board.id) }
    let(:project) { create(:project, user: user, wiki_page_name: 'my_wiki') }
    let(:board) { create(:board, project: project)}
    context 'without taskId' do
      before { get :show, id: id }

      context 'not found task' do
        let(:id) { 'asdf' }
        it { expect(response).to redirect_to('/') }
      end

      context 'found task' do
        let(:id) { task.id }
        it { expect(response.status).to redirect_to("/tasks/#{task.id}?board=#{task.board_id}&taskId=#{task.id}") }
      end
    end

    context 'with taskId and board' do
      before { get :show, id: id, taskId: id, board: board.id }
      context 'found task' do
        let(:id) { task.id }
        it { expect(response.status).to eq(200) }
      end
    end
  end

  describe '#accept' do
    subject(:make_request) { get(:accept, id: existing_task.id) }

    context 'when the task is accepted successful' do
      let(:existing_task) do
        FactoryGirl.create(:task, :with_associations, project: project, user: task_user, state: 'suggested_task')
      end
      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
      let(:only_follower) { FactoryGirl.create(:user, :confirmed_user) }
      let(:follower_and_member) { FactoryGirl.create(:user, :confirmed_user) }
      let(:task_user) { FactoryGirl.create(:user, :confirmed_user) }

      before do
        project_team = project.create_team(name: "Team#{project.id}")
        TeamMembership.create!(team_member: follower_and_member, team_id: project_team.id, role: 0)

        project.followers << only_follower
        project.followers << follower_and_member
        project.save!

        allow(NotificationMailer).to receive(:accept_new_task).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
      end

      it 'accepts the task' do
        expect(existing_task.suggested_task?).to be true
        expect(existing_task.accepted?).to be false

        make_request

        updated_task = Task.find(existing_task.id)
        expect(updated_task.suggested_task?).to be false
        expect(updated_task.accepted?).to be true
      end

      it 'redirects to project taskstab path' do
        make_request

        expect(response).to redirect_to(taskstab_project_url(existing_task.project, tab: 'tasks'))
      end

      it 'flashes the correct message' do
        make_request

        expect(flash[:notice]).to eq(I18n.t('tasks.accept.task_accepted'))
      end

      it 'sends an email to the involved users', :aggregate_failures do
        expect(NotificationMailer).to receive(:accept_new_task).exactly(2).times
        expect(message_delivery).to receive(:deliver_later).exactly(2).times

        make_request
      end
    end
  end

  describe '#incomplete' do
    let(:task) { create(:task, :reviewing, project: project, user: user) }
    let(:task_deadline) { 1.day.from_now.change(hour: 0) }

    before { put :incomplete, id: task.id, task_deadline: task_deadline }

    it { expect(response).to redirect_to taskstab_project_path(project, tab: 'tasks') }

    context "when task_deadline is nil or blank or has not been sent" do
      let!(:task_deadline) { nil }

      it { expect(response).to redirect_to(show_task_projects_path(id: task.id)) }
      it { expect(flash[:error]).to eq(I18n.t('tasks.incomplete.fail')) }
    end

    context "user is not leader or coordinator of current task's project" do
      let!(:project) { create(:project) }
      let!(:task) { create(:task, :reviewing, project: project) }

      it { expect(response).to redirect_to taskstab_project_path(project, tab: 'tasks') }
    end
  end

  describe '#send_email' do
    let(:task) { create(:task, :reviewing, project: project, user: user) }
    before { xhr :post, :send_email, email: user.email, task_id: task.id }

    it { expect(response.status).to eq(200) }
  end

  describe '#refund' do
    it { expect { post :refund, id: 'asdf' }.to raise_error(NotImplementedError) }
  end
end
