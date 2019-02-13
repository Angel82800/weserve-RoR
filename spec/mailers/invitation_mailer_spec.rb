require "rails_helper"

RSpec.describe InvitationMailer, type: :mailer do
  let(:receiver) { create(:user, :confirmed_user) }
  let(:new_leader) { create(:user, :confirmed_user) }
  let(:to_email) { receiver.email }
  let(:task) { create(:task, project: project, board: board) }
  let(:project) { create(:base_project, picture: nil)}
  let(:board) { create(:board, project: project)}

  describe '#invite_user' do
    subject(:email) do
      described_class.invite_user( to_email, receiver.display_name, task).deliver_now
    end

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(to_email)
    end

    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "InviterName" => receiver.display_name,
          "TaskUrl" => taskstab_project_url(project, tab: 'tasks', board: board.id, taskId: task.id),
          "TaskTitle" => task.title
        }
      }
    end
  end

  describe '#invite_user_for_project' do
    subject(:email) do
      described_class.invite_user_for_project( to_email, receiver.display_name, project.id).deliver_now
    end

    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "InviterName" => receiver.display_name,
          "ProjectUrl" => project_url(project.id),
          "ProjectTitle" => project.title,
        }
      }
    end

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(to_email)
    end
  end

  describe '#invite_leader' do
    let(:invitation) { create(:change_leader_invitation, new_leader: new_leader.email,  project: project) }
    subject(:email) do
      described_class.invite_leader(invitation.id).deliver_now
    end

    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "InviterName" => invitation.project.user.email,
          "ReceiverName" => invitation.new_leader,
          "ProjectUrl" => project_url(project.id),
          "ProjectTitle" => project.title,
        }
      }
    end

    it 'sends an email' do
      expect { email }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(invitation.new_leader)
    end
  end

  describe '#notify_previous_leader_for_new_leader' do
    subject(:email) do
      described_class.notify_previous_leader_for_new_leader( project: project, previous_leader: receiver).deliver_now
    end

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(receiver.email)
    end

    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "ReceiverName" => receiver.display_name,
          "NewLeaderName" => project.user.display_name,
          "ProjectUrl" => project_url(project.id),
          "ProjectTitle" => project.title,
        }
      }
    end
  end

  describe '#welcome_user' do
    subject(:email) do
      described_class.welcome_user(to_email).deliver_now
    end
    it 'sends an email' do
      expect { email }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(to_email)
    end
  end
end
