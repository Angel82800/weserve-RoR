class AddApplicationToDorequests < ActiveRecord::Migration
  def change
    add_column :do_requests, :application, :text
  end
end
