class AddNumberOfParticipantsToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :number_of_participants, :integer
  end
end
