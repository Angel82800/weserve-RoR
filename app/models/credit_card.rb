class CreditCard < ActiveRecord::Base
  enum status: [:new_card]

  belongs_to :user
end
