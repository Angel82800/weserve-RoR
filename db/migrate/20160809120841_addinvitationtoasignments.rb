class Addinvitationtoasignments < ActiveRecord::Migration
  def change
    add_column :assignments, :invitation_sent, :boolean
  end
end
