class CreateWikis < ActiveRecord::Migration
  def change
    create_table :wikis do |t|
      t.string :title
      t.text :description
      t.integer :project_id
      t.string :pictureone
      t.string :picturetwo
      t.string :picturethree
      t.string :picturefour
      t.string :picturefive

      t.timestamps null: false
    end
  end
end
