class AddProofOfExecutionToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :proof_of_execution, :text
   
  end
end
