class AddIsApprovalEnabledToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :is_approval_enabled, :boolean, default: false

    Project.all.each do |project|
      project.update_attribute(:is_approval_enabled, false)
    end
  end
end
