class CreateProjectEdits < ActiveRecord::Migration
  def change
    create_table :project_edits do |t|

      t.timestamps null: false
    end
  end
end
