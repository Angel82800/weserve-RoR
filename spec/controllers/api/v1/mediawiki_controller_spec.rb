require 'rails_helper'

RSpec.describe Api::V1::MediawikiController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:username) { user.username }
  let(:project) { FactoryGirl.create(:project) }
  let(:secret) { ENV['mediawiki_api_secret'] }
  let(:type) { 'edit' }
  let(:info) { "{'secret':'#{secret}',
                 'type': '#{type}',
                 'data':
                    {'page_name':'#{project.title}',
                     'editor_name': '#{username}',
                     'time': 123134324,
                     'approved': false  }
                }"
              }

  describe 'POST /api/v1/mediawiki/page_edited' do
    subject { response.status }
    before { post :page_edited, info }

    context 'Sends a request with correct params' do
      it { is_expected.to eq(200) }
    end

    context 'Sends a request with wrong secret' do
      let(:secret) { 'WrongKey123' }
      it { is_expected.to eq(401) }
    end

    context 'Sends a request with unkonwn type' do
      let(:type) { 'unkonwnType' }
      it { is_expected.to eq(400) }
    end

    context 'Sends a request with non existing project' do
      let(:username) { 'nothing' }
      it { is_expected.to eq(404) }
    end

    context 'Sends invalid info' do
      let(:info) { "invalid" }
      it { is_expected.to eq(400) }
    end
  end

  describe '#send_emails' do
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(controller).to receive(:render).and_return(true)
    end

    context "when missing params" do
      before do
        expect(controller).to receive(:bad_request)
      end
      it 'returns bad request when page_name is missing' do
        controller.send(:send_emails, nil, username )
      end

      it 'returns bad request when editor_username is missing' do
        controller.send(:send_emails, project.title, nil)
      end
    end

    context "when valid params" do
      before do
        project.followers = [ user, project.leader]
      end

      context "and editor is leader" do
        it "sends email to interested users but not to user" do
          allow(ProjectMailer).to receive(:project_text_edited_by_leader).and_return(message_delivery)
          expect(message_delivery).to receive(:deliver_later).exactly(1).times
          controller.send(:send_emails, project.title, project.leader.username)
        end
      end

      context "and editor is not leader" do

        context "and approval is enabled" do
          it "sends email to interested users but not to user" do
            project.update(is_approval_enabled: true)
            allow(ProjectMailer).to receive(:project_text_submitted_for_approval).and_return(message_delivery)
            expect(message_delivery).to receive(:deliver_later).exactly(1).times
            controller.send(:send_emails, project.title, username)
          end
        end

        context "and approval is not enabled" do
          it "sends email to interested users but not to user" do
            allow(ProjectMailer).to receive(:project_text_edited).and_return(message_delivery)
            expect(message_delivery).to receive(:deliver_later).exactly(1).times
            controller.send(:send_emails, project.title, username)
          end
        end
      end
    end
  end
end
