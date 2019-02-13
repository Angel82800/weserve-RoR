class TaskCompleteService
  attr_reader :task

  def initialize(task, user=nil)
    @task = task
    raise ArgumentError, "Incorrect argument type" unless task.is_a?(Task)
    raise ArgumentError, "Incorrect task state: #{task.state}" unless (task.reviewing? || (task.doing? && user && user.is_project_leader_or_coordinator_or_admin?(task.project)))
    raise ArgumentError, "Task's budget is too low and cannot be transfered"   unless task.free? || task.budget >= Task::MINIMUM_FUND_BUDGET
    raise ArgumentError, "Task fund level is too low and cannot be transfered" unless task.free? || task.current_fund >= task.budget
    #@task.update_current_fund! unless Rails.env.test? || ENV["mocked_payments"]
  end

  def complete!
    ActiveRecord::Base.transaction do
      mark_task_as_completed!
      send_funds_to_recipients! unless task.free
    end
    return true
  end

  def amount
    task.current_amount
  end

  def we_serve_part
    @we_serve_part ||= (amount * Payments::Base::Base.weserve_fee).to_i
  end

  def members_part
    @members_part ||= ((amount - we_serve_part) / task.team_memberships.size).to_i
  end

  def recipients
    @recipients ||= build_recipients
  end

  private
  def mark_task_as_completed!
    if task.complete!
      task.assignments.each do |assignment|
        assignment.complete!
      end
    end
  end

  def build_recipients
    recipients = task.team_memberships.map do
      {
        amount: members_part
      }
    end

    if we_serve_part > 0
      recipients << {
        amount: we_serve_part
      }
    end

    recipients
  end

  def send_funds_to_recipients!
    task.team_memberships.each do |membership|
      #membership.team_member.balance.increment!(:amount, members_part)
      membership.team_member.hold_balances.create(amount: members_part)
      # Create Transaction History log
      CreateTransactionHistoryService.update_amount(members_part, task, membership.team_member)
    end

    # Empty the balance of task(amount only) after distributing funds to recipients
    task.update_current_fund!(task.balance.funded, 0)
  end
end
