module UserWalletHelper
  def increase_decrease(transaction)
    t_class = transaction.class.name
    if t_class == PayoutTransaction.name || t_class == TransactionHistory.name && transaction.operation_type == 'decrease'
      '-'
    else
      '+'
    end
  end

  def transaction_amount(transaction)
    amount = balance_in_usd(transaction.amount)
    if transaction.class.name == PayoutTransaction.name
      "#{amount} (fee: #{ENV['symbol_currency']}#{balance_in_usd(transaction.fee)})"
    else
      amount
    end
  end

  def display_user(transaction)
    # show task if it source
    task = nil

    user =
      if transaction.class.name == TransactionHistory.name
        # to check when we have source is task !!!!
        is_user = transaction.source.class.name == User.name
        if is_user
          transaction.source
        else
          task = transaction.source
          transaction.source.user
        end
      else
        transaction.user
      end

    user_path = link_to(user.display_name, user_path(user.id))

    if task
      task_path = link_to(task.title, taskstab_project_path(task.project_id, taskId: task.id))
      "#{task_path}(#{user_path})"
    else
      user_path
    end

  end
end
