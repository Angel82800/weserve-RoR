class DeleteSummaryAndContentFormNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :content, :text
    remove_column :notifications, :summary, :string
  end
end
