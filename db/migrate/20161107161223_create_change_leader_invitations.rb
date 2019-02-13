class CreateChangeLeaderInvitations < ActiveRecord::Migration
  def change
    create_table :change_leader_invitations do |t|
      t.string   :new_leader
      t.datetime :sent_at
      t.datetime :accepted_at
      t.datetime :rejected_at
      t.string   :project_id
    end
  end
end
