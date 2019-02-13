require 'rails_helper'

describe DoRequestsController, type: :request do
  describe 'POST /do_requests' do
    subject(:make_request) { post("/do_requests", params) }
    let(:params) { { do_request: { task_id: task.id, application: 'Reason to do the task', free: false } } }
    let(:user_in_request) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:project) { FactoryGirl.create(:base_project, user: leader) }
    let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:coordinator) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:task) { FactoryGirl.create(:task, project: project) }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before { login_as(user_in_request, scope: :user, run_callbacks: false) }

    context 'successful creation of request' do
      before do
        allow(RequestMailer).to receive(:to_do_task).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
        allow_any_instance_of(Project).to receive(:project_coordinators).and_return([coordinator])
      end

      it 'triggers an email to be delivered later', aggregate_failures: true do
        expect(message_delivery).to receive(:deliver_later)
        expect(RequestMailer)
          .to receive(:to_do_task).with(leader, requester: user_in_request, task: task)
        expect(RequestMailer)
          .to receive(:to_do_task).with(coordinator, requester: user_in_request, task: task)
        make_request
      end

      it 'redirects to the project with the correct notice message', aggregate_failures: true do
          make_request

          expect(flash[:notice]).to eq(I18n.t('do_requests.create.success_and_sent'))
          expect(response).to redirect_to(task)
        end
    end
  end

  describe 'PUT /do_requests/:id/accept' do
    subject(:make_request) { put("/do_requests/#{do_request.id}/accept") }
    let(:params) { { do_request: { task_id: task.id, application: 'Reason to do the task', free: false } } }
    #let(:user_in_request) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:project) { FactoryGirl.create(:base_project, user: leader) }
    let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:current_fund) { 0 }
    let(:number_of_participants) { 0 }
    let(:task) do
      create(:task, :with_balance,
             project: project, user: leader, state: 'accepted',
             current_fund: current_fund, budget: 3200,
             number_of_participants: number_of_participants,
             target_number_of_participants: 1)
    end
    let(:do_request) { FactoryGirl.create(:do_request, task: task, project: task.project) }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
    let(:only_follower) { FactoryGirl.create(:user, :confirmed_user) }
    let(:follower_and_member) { FactoryGirl.create(:user, :confirmed_user) }

    before do
      project_team = project.create_team(name: "Team#{project.id}")
      TeamMembership.create!(team_member: leader, team_id: project_team.id, role: 1)
      TeamMembership.create!(team_member: follower_and_member, team_id: project_team.id, role: 0)

      project.followers << only_follower
      project.followers << follower_and_member
      project.save!

      allow(NotificationMailer).to receive(:task_started).and_return(message_delivery)
      login_as(leader, scope: :user, run_callbacks: false)
    end

    context 'successful creation of request' do
      before do
        allow(RequestMailer).to receive(:accept_to_do_task).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
      end

      it 'triggers an email to be delivered later', aggregate_failures: true do
        expect(message_delivery).to receive(:deliver_later)
        expect(RequestMailer).to receive(:accept_to_do_task).with(do_request: do_request)

        make_request
      end

      it 'redirects to the project with the correct notice message', aggregate_failures: true do
        make_request

        expect(flash[:notice]).to eq(I18n.t('do_requests.accept.success'))
        expect(response).to redirect_to(taskstab_project_path(do_request.project, tab: 'requests'))
      end

      context 'when the task is eligible to move to doing' do

        it 'change state task', aggregate_failures: true do
          task.balance.update(funded: 3200)
          make_request
          expect{task.reload}.to change(task, :state).from("accepted").to("doing")
        end

        it 'sends an email to the involved users', :aggregate_failures do
          task.balance.update(funded: 3200)
          expect(task.project.followers.count).to eq(3)
          # exclude project user
          # expect(NotificationMailer).to receive(:notify_assignee_added_to_task).exactly(1).times
          expect(NotificationMailer).to receive(:task_started).exactly(2).times
          make_request
        end
      end

      it 'when the task has not enough funds', aggregate_failures: true do
        make_request
        expect{task.reload}.to_not change(task, :state)
      end
    end
  end

  describe 'PUT /do_requests/:id/reject' do
    subject(:make_request) { put("/do_requests/#{do_request.id}/reject") }
    let(:params) { { do_request: { task_id: task.id, application: 'Reason to do the task', free: false } } }
    #let(:user_in_request) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:project) { FactoryGirl.create(:base_project, user: leader) }
    let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:task) { FactoryGirl.create(:task, project: project) }
    let(:do_request) { FactoryGirl.create(:do_request, task: task, project: task.project) }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before { login_as(leader, scope: :user, run_callbacks: false) }

    context 'successful creation of request' do
      before do
        allow(RequestMailer).to receive(:reject_to_do_task).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
      end

      it 'triggers an email to be delivered later', aggregate_failures: true do
        expect(message_delivery).to receive(:deliver_later)
        expect(RequestMailer).to receive(:reject_to_do_task).with(do_request: do_request)

        make_request
      end

      it 'redirects to the project with the correct notice message', aggregate_failures: true do
        make_request

        expect(flash[:notice]).to eq(I18n.t('do_requests.reject.success'))
        expect(response).to redirect_to(taskstab_project_path(do_request.project, tab: 'requests'))
      end
    end
  end
end
