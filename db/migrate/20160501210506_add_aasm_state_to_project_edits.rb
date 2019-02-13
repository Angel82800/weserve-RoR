class AddAasmStateToProjectEdits < ActiveRecord::Migration
  def change
    add_column :project_edits, :aasm_state, :string, :default => 'pending'
  end
end
