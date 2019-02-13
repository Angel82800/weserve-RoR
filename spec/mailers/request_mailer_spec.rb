require 'rails_helper'

RSpec.describe RequestMailer, type: :mailer do
  include ActionView::Helpers::UrlHelper
  include MailerHelper

  let(:project) { FactoryGirl.create(:project, user: leader) }
  let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
  let(:applicant) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }

  describe '#apply_to_get_involved_in_project' do
    subject(:email) { described_class.apply_to_get_involved_in_project(applicant: applicant, project: project, request_type: request_type).deliver_now }

    let(:request_type) {2}
    let(:mailjet_variables) {
      {
          "ReceiverName" => leader.display_name,
          "ApplicantName" => applicant.display_name,
          "RequestType" => request_type,
          "ProjectTitle" => project.title,
          "ProjectUrl" => project_url(project.id),
          "RequestTabUrl" => taskstab_project_url(project, tab: 'requests')
      }
    }

    it_behaves_like 'mailjet api email'

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(leader.email)
    end



    context 'when request_type is coordinator', aggregate_failures: true do
      let(:request_type) { 'Coordinator' }
      it "has correct request type" do
        expect(email.delivery_method.settings["Variables"]["RequestType"]).to eq('Coordinator')
      end
    end

    context 'when request_type is Lead Editor', aggregate_failures: true do
      let(:request_type) { 'Lead Editor' }

      it "has correct request type" do
        expect(email.delivery_method.settings["Variables"]["RequestType"]).to eq('Lead Editor')
      end
    end
  end

  describe '#positive_response_in_project_involvement' do
    subject(:email) { described_class.positive_response_in_project_involvement(apply_request: apply_request).deliver_now }
    let(:user_in_request) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:apply_request) { FactoryGirl.create(:lead_editor_request, user: user_in_request, project: project) }
    let(:project) { FactoryGirl.create(:project, user: leader) }
    let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:request_type) { apply_request.request_type.try(:tr, '_', ' ') }

    let(:mailjet_variables) {
      {
          "LeaderName" => leader.display_name,
          "RequestType" => request_type,
          "ProjectTitle" => project.title,
          "ProjectUrl" => project_url(project.id),
      }
    }

    it_behaves_like 'mailjet api email'

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user_in_request.email)
    end

    it_behaves_like 'mailjet api email'
  end

  describe '#negative_response_in_project_involvement' do
    subject(:email) { described_class.negative_response_in_project_involvement(apply_request: apply_request).deliver_now }
    let(:user_in_request) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:apply_request) { FactoryGirl.create(:lead_editor_request, user: user_in_request, project: project) }
    let(:project) { FactoryGirl.create(:project, user: leader) }
    let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:request_type) { apply_request.request_type.try(:tr, '_', ' ') }

    let(:mailjet_variables) {
      {
          "LeaderName" => leader.display_name,
          "RequestType" => request_type,
          "ProjectTitle" => project.title,
          "ProjectUrl" => project_url(project.id),
      }
    }

    it_behaves_like 'mailjet api email'

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user_in_request.email)
    end
  end

  describe '#to_do_task' do
    subject(:email) { described_class.to_do_task(leader, requester: user_in_request, task: task).deliver_now }
    let(:user_in_request) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:project) { FactoryGirl.create(:project, user: leader) }
    let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }

    let(:task) { FactoryGirl.create(:task, project: project) }

    let(:mailjet_variables) {
      {
          "RequesterName" => user_in_request.display_name,
          "TaskTitle" => task.title,
          "TaskUrl" => taskstab_project_url(project, tab: 'tasks', board: task.board_id, taskId: task.id),
          "RequestTabUrl" => taskstab_project_url(project, tab: 'requests'),
      }
    }

    it_behaves_like 'mailjet api email'

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(leader.email)
    end
  end

  describe '#accept_to_do_task' do
    subject(:email) { described_class.accept_to_do_task(do_request: do_request).deliver_now }
    let(:user_in_request) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:project) { FactoryGirl.create(:project, user: leader) }
    let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:do_request) { FactoryGirl.create(:do_request, user: user_in_request, project: project, task: task) }
    let(:task) { FactoryGirl.create(:task, project: project) }

    let(:mailjet_variables) {
      {
          "RequesterName" => user_in_request.display_name,
          "TaskTitle" => task.title,
          "TaskUrl" => taskstab_project_url(project, tab: 'tasks', board: task.board_id, taskId: task.id),
          "ProjectTitle" => project.title,
          "ProjectUrl" => project_url(project.id)
      }
    }

    it_behaves_like 'mailjet api email'

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user_in_request.email)
    end
  end

  describe '#reject_to_do_task' do
    subject(:email) { described_class.reject_to_do_task(do_request: do_request).deliver_now }
    let(:user_in_request) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:project) { FactoryGirl.create(:project, user: leader) }
    let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:do_request) { FactoryGirl.create(:do_request, user: user_in_request, project: project, task: task) }
    let(:task) { FactoryGirl.create(:task, project: project) }

    let(:mailjet_variables) {
      {
        "RequesterName" => user_in_request.display_name,
        "TaskTitle" => task.title,
        "TaskUrl" => taskstab_project_url(project, tab: 'tasks', board: task.board_id, taskId: task.id),
        "ProjectTitle" => project.title,
        "ProjectUrl" => project_url(project.id)
      }
    }

    it_behaves_like 'mailjet api email'

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user_in_request.email)
    end
  end
end
