class AddFreeToDoRequests < ActiveRecord::Migration
  def change
    add_column :do_requests, :free, :boolean
  end
end
