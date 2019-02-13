class CreateProjectRates < ActiveRecord::Migration
  def change
    create_table :project_rates do |t|
      t.belongs_to :project
      t.belongs_to :user
      t.integer :rate, default: 0

      t.timestamps null: false
    end
  end
end
