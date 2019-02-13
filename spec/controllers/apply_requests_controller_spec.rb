require 'rails_helper'

RSpec.describe ApplyRequestsController, type: :request do
  let(:project) { FactoryGirl.create(:project, user: user) }
  let(:user) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
  let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
  let(:user_in_request) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }

  before { login_as(user, scope: :user, run_callbacks: false) }

  describe 'POST /apply_requests/:id/accept' do
    subject(:make_request) { post("/apply_requests/#{apply_request.id}/accept") }
    context 'when user accepts an other user for Lead Editor' do
      let!(:apply_request) { FactoryGirl.create(:lead_editor_request, user: user_in_request, project: project) }

      before do
        allow(RequestMailer).to receive(:positive_response_in_project_involvement).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
      end

      it 'calls the team service with the correct arguments' do
        expect(TeamService)
          .to receive(:add_team_member).with(
            apply_request.project.team,
            apply_request.user,
            TeamMembership.roles[:lead_editor]
          ).and_call_original

        make_request
      end

      it 'sends an email to the user', aggregate_failures: true do
        expect(RequestMailer).to receive(:positive_response_in_project_involvement).with(apply_request: apply_request)
        expect(message_delivery).to receive(:deliver_later)

        make_request
      end
    end

    context 'when user accepts an other user for Coordinator' do
      context 'when user accepts an other user for Coordinator' do
        let!(:apply_request) { FactoryGirl.create(:coordinator_request, user: user_in_request, project: project) }

        before do
          allow(RequestMailer).to receive(:positive_response_in_project_involvement).and_return(message_delivery)
          allow(message_delivery).to receive(:deliver_later)
        end

        it 'calls the team service with the correct arguments' do
          expect(TeamService)
            .to receive(:add_team_member).with(
              apply_request.project.team,
              apply_request.user,
              TeamMembership.roles[:coordinator]
            ).and_call_original

          make_request
        end

        it 'sends an email to the user', aggregate_failures: true do
          expect(RequestMailer).to receive(:positive_response_in_project_involvement).with(apply_request: apply_request)
          expect(message_delivery).to receive(:deliver_later)

          make_request
        end
      end
    end
  end

  describe 'POST /apply_requests/:id/reject' do
    subject(:make_request) { post("/apply_requests/#{apply_request.id}/reject") }

    before do
      allow(RequestMailer).to receive(:negative_response_in_project_involvement).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)
    end

    context 'when user rejects an other user for Lead Editor' do
      let!(:apply_request) { FactoryGirl.create(:lead_editor_request, user: user_in_request, project: project) }


      it 'sends an email to the user', aggregate_failures: true do
        expect(RequestMailer).to receive(:negative_response_in_project_involvement).with(apply_request: apply_request)
        expect(message_delivery).to receive(:deliver_later)

        make_request
      end

      it 'updates the rejected column of the apply_request' do
        expect { make_request }.to change { apply_request.reload.rejected_at }
      end
    end

    context 'when user rejects an other user for coordinator' do
      let!(:apply_request) { FactoryGirl.create(:coordinator_request, user: user_in_request, project: project) }

      it 'updates the rejected column of the apply_request' do
        expect { make_request }.to change { apply_request.reload.rejected_at }
      end

      it 'sends an email to the user', aggregate_failures: true do
        expect(RequestMailer).to receive(:negative_response_in_project_involvement).with(apply_request: apply_request)
        expect(message_delivery).to receive(:deliver_later)

        make_request
      end
    end
  end
end
