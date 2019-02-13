class Bank < ActiveRecord::Base
  enum status: [:new_bank]

  belongs_to :user
end
