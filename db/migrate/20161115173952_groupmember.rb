class Groupmember < ActiveRecord::Migration

  def change
    create_table :groupmembers do |t|
      t.string :name
      t.references :user, index: true, foreign_key: true
      t.references :chatroom, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
