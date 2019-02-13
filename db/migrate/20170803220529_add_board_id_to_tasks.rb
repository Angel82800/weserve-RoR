class AddBoardIdToTasks < ActiveRecord::Migration
  def change
    add_reference :tasks, :board, index: true, foreign_key: true
  end
end
