class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.string :country
      t.string :picture
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_index :projects, :deleted_at
  end
end
