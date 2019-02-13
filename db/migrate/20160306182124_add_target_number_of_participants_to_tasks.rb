class AddTargetNumberOfParticipantsToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :target_number_of_participants, :integer
  end
end
