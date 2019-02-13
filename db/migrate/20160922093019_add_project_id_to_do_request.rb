class AddProjectIdToDoRequest < ActiveRecord::Migration
  def change
    add_column :do_requests, :project_id, :integer

  end
end
