class TransactionHistory < ActiveRecord::Base
  belongs_to :tran_record, polymorphic: true
  belongs_to :source, polymorphic: true

  paginates_per 20

  scope :all_transactions, lambda {
    find_by_sql("
      SELECT  id, created_at, 'PaymentTransaction' AS entity_type
      FROM payment_transactions
      UNION ALL
      SELECT id, created_at, 'TransactionHistory' AS  entity_type
      FROM transaction_histories
      UNION ALL
      SELECT id, created_at, 'PayoutTransaction' AS  entity_type
      FROM payout_transactions
    ")
  }

  def self.transactions_objects(transactions)
    t_array = []
    tr = transactions.group_by { |t| t['entity_type'] }

    # get transactions objects by ids,
    # 'k' = model name
    # 'v' = array of objects with 'k' model name
    tr.each { |k, v| t_array << k.constantize.where(id: v.map{ |i| i['id'] }) }

    t_array.flatten.sort_by(&:created_at).reverse
  end

  # to print destination/source record data
  def record_type_display_name(type = 'source')
    record = type == 'destination' ? tran_record : source
    is_user = record.class.name == User.name
    user = is_user ? record : record.user

    user_path = Rails.application.routes.url_helpers.user_path(user.id)
    user_link = ActionController::Base.helpers.link_to(user.display_name, user_path)

    if is_user
      user_link
    else
      path = Rails.application.routes.url_helpers.taskstab_project_path(record.project_id, board: record.board_id, taskId: record.id)
      link = ActionController::Base.helpers.link_to(record.title, path)

      "task #{link}(#{user_link})"
    end
  end

  def display_transaction
    operation =
      if operation_type == 'increase'
        I18n.t('users.user_transactions.received_from')
      else
        I18n.t('users.user_transactions.sent_to')
      end

    "#{operation}: #{record_type_display_name}"
  end
end
