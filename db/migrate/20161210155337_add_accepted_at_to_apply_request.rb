class AddAcceptedAtToApplyRequest < ActiveRecord::Migration
  def change
    add_column :apply_requests, :accepted_at, :datetime
    add_column :apply_requests, :rejected_at, :datetime
    remove_column :apply_requests, :status, :integer
  end
end
