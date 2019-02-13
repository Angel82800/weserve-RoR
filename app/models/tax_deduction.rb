class TaxDeduction < ActiveRecord::Base
  belongs_to :user

  validates :name, :address, :postal_code, :city, :country, presence: true
end
