class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :number_of_members
      t.integer :number_of_projects
      t.text :mission

      t.timestamps null: false
    end
  end
end
