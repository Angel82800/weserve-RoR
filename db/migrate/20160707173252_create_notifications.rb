class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :type
      t.string :summary
      t.text :content

      t.timestamps null: false
    end
  end
end
