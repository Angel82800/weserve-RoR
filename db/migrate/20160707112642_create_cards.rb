class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :title
      t.string :status
      t.string :list

      t.timestamps null: false
    end
  end
end
