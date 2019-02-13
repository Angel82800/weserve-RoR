class CreateProfileComments < ActiveRecord::Migration
  def change
    create_table :profile_comments do |t|
      t.integer :commenter_id
      t.integer :receiver_id
      t.text :comment_text

      t.timestamps null: false
    end

    add_index :profile_comments, :receiver_id
    add_index :profile_comments, :commenter_id
  end
end
