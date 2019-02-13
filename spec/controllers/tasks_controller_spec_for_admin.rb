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

  describe '#remove_assignee' do
    subject(:make_request) { get(:remove_assignee, id: existing_task.id, membership_id: @team_membership.id) }

    context 'remove assignee' do
      let(:existing_task) do
        FactoryGirl.create(
          :task,
          :with_balance,
          project: project,
          user: user,
          state: 'accepted',
          current_fund: 3000.0,
          budget: 3000.0,
          number_of_participants: 1,
          target_number_of_participants: 1
        )
      end

      before do
        project_team = project.create_team(name: "Team#{project.id}")
        @team_membership = TeamMembership.create!(team_member: user, team_id: project_team.id, role: 1)
        @team_membership.tasks << existing_task
        @team_membership.save!
        TaskMember.create(task_id: existing_task.id, team_membership_id: @team_membership.id)
        existing_task.save!
      end

      it 'decrease number of participants' do
        expect { make_request }.to change { existing_task.reload.number_of_participants }.from(1).to(0)
      end

      it 'redirects to project taskstab path' do
        make_request
        expect(response).to redirect_to(taskstab_project_url(existing_task.project, tab: 'tasks', board: existing_task.board_id, taskId: existing_task.id))
      end

      it 'flashes the correct message' do
        make_request
        expect(flash[:notice]).to eq(I18n.t('tasks.remove_assignee.success'))
      end
    end
  end

  describe '#add_assignee' do
    subject(:make_request) { get(:add_assignee, id: existing_task.id, user_id: user.id) }

    context 'add assignee' do
      let(:existing_task) do
        FactoryGirl.create(
          :task,
          :with_balance,
          project: project,
          user: user,
          state: 'accepted',
          current_fund: 3000.0,
          budget: 3000.0,
          number_of_participants: 0,
          target_number_of_participants: 1
        )
      end
      
      before do
        project_team = project.create_team(name: "Team#{project.id}")
        @team_membership = TeamMembership.create!(team_member: user, team_id: project_team.id, role: 1)
      end

      it 'decrease number of participants' do
        expect { make_request }.to change { existing_task.reload.number_of_participants }.from(0).to(1)
      end

      it 'redirects to project taskstab path' do
        make_request
        expect(response).to redirect_to(taskstab_project_url(existing_task.project, tab: 'tasks', board: existing_task.board_id, taskId: existing_task.id))
      end

      it 'flashes the correct message' do
        make_request
        expect(flash[:notice]).to eq(I18n.t('tasks.add_assignee.success'))
      end
    end
  end
end
