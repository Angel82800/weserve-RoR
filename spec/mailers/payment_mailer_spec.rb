require 'rails_helper'

RSpec.describe PaymentMailer, type: :mailer do
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper
  include MailerHelper

  let(:payer) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
  let(:project) { FactoryGirl.create(:project, user: leader) }
  let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
  let(:amount) { 114624 }
  let(:task) { FactoryGirl.create(:task, project: project) }

  def mailjet_task_variables(user, task, project)
    {
      "ReceiverName" => user.display_name,
      "TaskTitle" => task.title,
      "TaskUrl" => taskstab_project_url(project, tab: 'tasks', board: task.board_id, taskId: task.id),
      "ProjectTitle" => project.title,
      "ProjectUrl" => project_url(project.id)
    }
  end

  describe '#fully_funded_task' do
    subject(:email) { described_class.fully_funded_task(task: task, receiver: leader).deliver_now }

    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        mailjet_task_variables(leader, task, project)
      }
    end
  end

  describe '#fund_task' do
    subject(:email) { described_class.fund_task(payer: payer, task: task, receiver: leader, amount: amount).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(leader.email)
    end

    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "ReceiverName" => leader.display_name,
          "Amount" => 1146.24,
          "CurrencySymbol" => ENV['symbol_currency'],
          "PayerName" => payer.display_name,
          "TaskTitle" => task.title,
          "TaskUrl" => taskstab_project_url(project, tab: 'tasks', board: task.board_id, taskId: task.id)
        }
      }
    end
  end
end
