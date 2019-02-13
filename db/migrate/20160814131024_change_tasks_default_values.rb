class ChangeTasksDefaultValues < ActiveRecord::Migration
  def change
    change_column_default(:tasks, :number_of_participants, 0)
    change_column_default(:tasks, :target_number_of_participants, 0)
  end
end
