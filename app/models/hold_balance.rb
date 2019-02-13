class HoldBalance < ActiveRecord::Base
  belongs_to :user

  scope :get_older_record, -> { where("created_at <= ?", get_days.to_i.days.ago) }

  def self.get_days
    ENV["account_balance_hold"] || 7
  end
end
