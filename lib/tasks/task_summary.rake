namespace :task_summary do
  desc "Send summary with new messages received by user"
  task send_summary_notification: :environment do
    SendSummaryJob.perform_later
    Rails.logger.info "Sent summary notifications to users..."
  end
end
