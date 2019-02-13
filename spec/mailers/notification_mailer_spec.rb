require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  include ActionView::Helpers::UrlHelper
  include MailerHelper

  let(:user) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
  let(:project) { FactoryGirl.create(:project, user: leader) }
  let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
  let(:other_user) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
  let(:admin) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
  let(:task) { FactoryGirl.create(:task, project: project, user: leader) }
  let(:task_comment) { FactoryGirl.create(:task_comment, task: task, user: user) }


  def variables_for_task_with_project(task, receiver, project)
    {
      "ReceiverName" => receiver.display_name,
      "TaskTitle" => task.title,
      "TaskUrl" => taskstab_project_url(project, tab: 'tasks', board: task.board_id, taskId: task.id),
      "ProjectTitle" => project.title,
      "ProjectUrl" => project_url(project.id)
    }
  end

  def variables_for_task(task, receiver)
    {
      "ReceiverName" => receiver.display_name,
      "TaskTitle" => task.title,
      "TaskUrl" => taskstab_project_url(project, tab: 'tasks', board: task.board_id, taskId: task.id),
    }
  end

  def variables_for_project(receiver, project)
    {
      "ReceiverName" => receiver.display_name,
      "ProjectTitle" => project.title,
      "ProjectUrl" => project_url(project.id)
    }
  end


  describe '#invite_admin' do
    subject(:email) { described_class.invite_admin(user, project ).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_project(user, project)
      }
    end
  end

  describe '#suggest_task' do
    subject(:email) { described_class.suggest_task(user, task).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end

    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_project(user, project)
          .merge({ "SuggestorName" => leader.display_name })
      }
    end
  end

  describe '#accept_new_task' do
    subject(:email) { described_class.accept_new_task(receiver: user, task: task).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, user, project)
      }
    end
  end

  describe '#reject_task_to_suggested' do
    subject(:email) { described_class.reject_task_to_suggested(task, user).deliver_now }
    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, user, project)
      }
    end
  end

  describe '#task_started' do
    subject(:email) { described_class.task_started(acting_user: leader, task: task, receiver: user).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, user, project)
          .merge({ "UserName" => leader.display_name })
      }
    end
  end

  describe '#task_changed' do
    subject(:email) { described_class.task_changed(reviewer: leader, task: task, receiver: user).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end

    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, user, project)
          .merge({ "ReviewerName" => leader.display_name })
      }
    end
  end

  describe '#under_review_task' do
    subject(:email) { described_class.under_review_task(reviewee: user, task: task, receiver: leader).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(leader.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, leader, project)
          .merge({ "RevieweeName" => user.display_name })
      }
    end
  end

  describe '#task_back_inprogress' do
    subject(:email) { described_class.task_back_inprogress( task, user).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, user, project)
      }
    end
  end

  describe '#revision_approved' do
    subject(:email) { described_class.revision_approved(project: project, receiver: user, approver: leader).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_project(user, project)
          .merge({ "ApproverName" => leader.display_name })
      }
    end
  end


  describe '#task_change_rejected' do
    subject(:email) { described_class.task_change_rejected(receiver: user, task: task, approver: leader).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, user, project)
          .merge({ "ApproverName" => leader.display_name })
      }
    end
  end

  describe '#task_change_approved' do
    subject(:email) { described_class.task_change_approved(receiver: user, task: task, approver: leader).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, user, project)
          .merge({ "ApproverName" => leader.display_name })
      }
    end
  end

  describe '#notify_user_for_rejecting_new_task' do
    subject(:email) { described_class.notify_user_for_rejecting_new_task(receiver: user, task: task, project: project).deliver_now }
    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, user, project)
      }
    end
  end

  describe '#notify_others_for_rejecting_new_task' do
    subject(:email) { described_class.notify_others_for_rejecting_new_task(receiver: user, task: task, project: project).deliver_now }
    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, user, project)
      }
    end
  end



  describe '#comment' do
    let(:board) { FactoryGirl.create(:board, project: project) }
    subject(:email) { described_class.comment(task_comment: task_comment, receiver: leader, board_id: board.id).deliver_now }
    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(leader.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task(task, leader)
          .merge({
                   "UserName" => user.display_name,
                   "Comment" => task_comment.body,
                   "TaskUrl" => taskstab_project_url(task_comment.task.project.id, tab: 'tasks', board: board.id, taskId: task_comment.task.id)
                 })
      }
    end
  end

  describe '#task_deleted' do
    subject(:email) { described_class.task_deleted(task: task, project: project, receiver: leader, admin: admin).deliver_now }
    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(leader.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, leader, project)
          .merge({ "AdminName" => admin.display_name })
      }
    end
  end

  describe '#task_completed' do
    subject(:email) { described_class.task_completed(task: task, receiver: user, reviewer: admin).deliver_now }
    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, user, project)
          .merge({ "ReviewerName" => admin.display_name })
      }
    end
  end

  describe '#task_incomplete' do
    subject(:email) { described_class.task_incomplete(task: task, receiver: user, reviewer: admin).deliver_now }
    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task_with_project(task, user, project)
          .merge({ "ReviewerName" => admin.display_name })
      }
    end
  end

  describe '#cancel_request_task' do
    subject(:email) { described_class.cancel_request_task(task, leader, user).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end

    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "TaskTitle" => task.title,
          "AssigneeName" => leader.display_name,
          "ReceiverName" => user.display_name,
          "ConfirmationUrl" => taskstab_project_url(project, tab: 'tasks', cancel_confirm: true, task_id: task.id, assignee_id: leader.id)
        }
      }
    end
  end

  describe '#notify_assignee_on_removing_from_task' do
    subject(:email) { described_class.notify_assignee_on_removing_from_task(user, task).deliver_now }
    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task(task, user)
      }
    end
  end

  # describe '#notify_assignee_added_to_task' do
  #   let(:emails) { [Faker::Internet.email] }
  #   subject(:email) { described_class.notify_assignee_added_to_task(user, task, emails ).deliver_now }
  #   it 'has the correct receiver email address' do
  #     expect(email.to.first).to eq(user.email)
  #   end
  #
  #   it 'has the other emails to cc' do
  #     expect(email.cc.first).to eq(emails.first)
  #   end
  #   it_behaves_like 'mailjet api email' do
  #     let(:mailjet_variables) {
  #       variables_for_task(task, user)
  #     }
  #   end
  # end

  describe '#notify_interested_user_on_removing_from_task' do

    subject(:email) { described_class.notify_interested_user_on_removing_from_task(other_user, user, task).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        variables_for_task(task, user).merge({ "AssigneeName" => other_user.display_name })
      }

    end
  end

  describe '#new_message' do
    subject(:email) { described_class.new_message(group_message.id, user.id).deliver_now }
    let(:chatroom) { create(:chatroom) }
    let(:group_message) { create(:group_message, user: other_user) }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "ReceiverName" => user.display_name,
          "UserName" => other_user.display_name,
          "Message" => group_message.message
        }
      }
    end
  end

  describe '#stripe_account_update' do
    subject(:email) { described_class.stripe_account_update(user.id, "unverified").deliver_now }
    let!(:custom_account) { create(:custom_account, user: user) }
    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "ReceiverName" => user.display_name,
          "PreviousState" => "unverified",
          "CurrentState" => "pending"
        }
      }
    end
  end

  describe '#block_withdraw' do
    subject(:email) { described_class.block_withdraw(user.id).deliver_now }
    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "ReceiverName" => user.display_name,
        }
      }
    end
  end

  describe '#send_warning_mail' do
    let(:date_now) { Time.now.to_date }
    subject(:email) { described_class.send_warning_mail(user.id, date_now).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(user.email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "ReceiverName" => user.display_name,
          "DueDate" => date_now
        }
      }
    end
  end

  describe '#send_error_to_admin' do
    subject(:email) { described_class.send_error_to_admin(user, 'Error Message').deliver_now }

    it 'has the correct receiver email address' do
      admin_email = ENV["admin_notification_email"]
      expect(email.to.first).to eq(admin_email)
    end
    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "UserDetail" => "#{user.display_name}(#{user.id})",
          "Error" => 'Error Message'
        }
      }
    end
  end

  describe '#notify_new_leader_for_project' do

    subject(:email) { described_class.notify_new_leader_for_project(project: project, previous_leader: user).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(leader.email)
    end

    it_behaves_like 'mailjet api email' do
      let(:mailjet_variables) {
        {
          "ReceiverName" => leader.display_name,
          "PreviousLeaderName" => user.display_name,
          "ProjectTitle" => project.title,
          "ProjectUrl" => project_url(project.id)
        }
      }
    end
  end
end
