class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.text :notes
      t.text :todos
      t.string :owner
      t.string :status
      t.text :body

      t.timestamps null: false
    end
  end
end
