class CreateTransactionHistoryService

  def initialize(entity, transaction_amount, transaction_type, source_entity)
    @entity = entity
    @transaction_type = transaction_type
    @transaction_amount = transaction_amount
    @source_entity = source_entity
  end


  def perform!
    @entity.transaction_histories.create(amount: @transaction_amount, entity: @entity.id,
                            entity_balance: @entity.try(:balance).try(:id), source: @source_entity,
                            operation_type: @transaction_type )
  end

  class << self
    # call this method for user, for adding transactionrecord
    def update_amount(amount, source_entity = nil, destination_entity = nil)
      decrease_amount(source_entity, amount, destination_entity) unless source_entity.nil?
      increase_amount(destination_entity, amount, source_entity) unless destination_entity.nil?
    end

    # call this method for task, for adding transactionrecord
    def update_fund(source_entity, destination_entity, amount)
      decrease_amount(source_entity, amount, destination_entity)
      increase_funded(destination_entity, amount, source_entity)
    end


    def increase_amount(entity, amount, source_entity)
      new(entity, amount, 'increase', source_entity).perform!
    end

    def increase_funded(entity, fund, source_entity)
      new(entity, fund, 'increase', source_entity).perform!
    end

    def decrease_amount(entity, amount, source_entity)
      new(entity, amount, 'decrease', source_entity).perform!
    end

    def decrease_funded(entity, fund, source_entity)
      new(entity, fund, 'decrease', source_entity).perform!
    end


  end
end
