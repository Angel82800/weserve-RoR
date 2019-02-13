class FundTransactionService
  def self.perform_post_operation(task, user, amount)
    @task = task
    @user = user
    @amount = amount

    comm_obj = CommissionCalculation.new(amount, user)
    @amount_after_fee = comm_obj.amount_after_fee

    add_balance_to_user
    # deduct_balance_from_user
    add_balance_to_task
  end

  class << self
    def add_balance_to_user
       @user.balance.increment!(:amount, @amount_after_fee)
       # because we have PaymentTransaction
       # CreateTransactionHistoryService.update_amount(@amount, nil, @user )
    end

    # def deduct_balance_from_user
    #   @user.balance.decrement!(:amount, @amount)
    #   CreateTransactionHistoryService.update_amount(@amount, @user)
    # end

    def add_balance_to_task
       @task.increment_fund(@amount)
       @task.increment_amount(@amount_after_fee)
       @user.balance.decrement!(:amount, @amount_after_fee)
       CreateTransactionHistoryService.update_fund(@user, @task, @amount)
    end
  end
end
