class CreateWorkRecords < ActiveRecord::Migration
  def change
    create_table :work_records do |t|

      t.timestamps null: false
    end
  end
end
