require 'rails_helper'

RSpec.describe ProjectMailer, type: :mailer do
  let(:user) { FactoryGirl.create(:user) }
  let(:receiver) { FactoryGirl.create(:user) }
  let(:project) { FactoryGirl.create(:project) }
  let(:mailjet_variables) {
    {
        "ReceiverName" => receiver.display_name,
        "EditorName" => user.display_name,
        "ProjectTitle" => project.title,
    }
  }

  describe '#project_text_edited_by_leader' do
    subject(:email) { described_class.project_text_edited_by_leader(editor_id: user.id, project_id: project.id, receiver_id: receiver.id).deliver_now }
    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(receiver.email)
    end

    it_behaves_like 'mailjet api email'
  end

  describe '#project_text_submitted_for_approval' do
    subject(:email) { described_class.project_text_submitted_for_approval(editor_id: user.id, project_id: project.id, receiver_id: receiver.id).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(receiver.email)
    end

    it_behaves_like 'mailjet api email'
  end

  describe '#project_text_edited' do
    subject(:email) { described_class.project_text_edited(editor_id: user.id, project_id: project.id, receiver_id: receiver.id).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(receiver.email)
    end

    it_behaves_like 'mailjet api email'
  end

end
