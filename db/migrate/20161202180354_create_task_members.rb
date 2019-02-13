class CreateTaskMembers < ActiveRecord::Migration
  def change
    create_table :task_members do |t|
      t.references :team_membership, index: true, foreign_key: true
      t.references :task, index: true, foreign_key: true
      t.datetime :created_at
    end
  end
end
