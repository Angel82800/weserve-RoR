require 'rails_helper'

describe TaskCommentsController, type: :request do
  describe 'POST /projects/:project_id/tasks/:task_id/task_comments' do
    subject(:make_request) { post("/projects/#{project.id}/tasks/#{task.id}/task_comments", params, { 'HTTP_REFERER' => 'http://www.example.com' }) }
    let(:task) { FactoryGirl.create(:task, project: project) }
    let(:project) { FactoryGirl.create(:base_project, user: user) }
    let(:user) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:only_follower) { FactoryGirl.create(:user, :confirmed_user) }

    before do
      login_as(user, scope: :user, run_callbacks: false)

      project_team = project.create_team(name: "Team#{project.id}")
      TeamMembership.create(team_member_id: user.id, team_id: project_team.id, role: 1)

      project.followers << only_follower

      allow(NotificationMailer).to receive(:comment).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)
    end

    context 'when comment is submitted ' do
      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
      let(:params) do
        {
          task_comment: {
            body: 'This is a comment',
            task_id: task.id,
            user_id: user.id
          },
          commit: 'Send', project_id: project.id, task_id: task.id,
          format: 'html'
        }
      end

      it 'saves the comment' do
        expect { make_request }.to change { TaskComment.count }.by(1)
      end

      it 'sends an email to the involved users', :aggregate_failures do
        expect(NotificationMailer).to receive(:comment).exactly(1).times
        expect(message_delivery).to receive(:deliver_later).exactly(1).times
        allow(project).to receive(:notifiable_leader_and_coordinators).and_return([project.leader])
        make_request
      end
    end
  end
end
