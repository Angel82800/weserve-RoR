class TransactionHistoriesController < ApplicationController
  before_action :authenticate_user!

   def index
     transactions = TransactionHistory.all_transactions
     sorted_transactions = transactions.sort_by { |r| r['created_at'] }.reverse
     paginated_transactions = Kaminari.paginate_array(sorted_transactions).page(params[:page]).per(10)
     all_transactions = TransactionHistory.transactions_objects(paginated_transactions)
     paginated_transactions.replace(all_transactions)

     @transaction_histories = paginated_transactions
   end
end
