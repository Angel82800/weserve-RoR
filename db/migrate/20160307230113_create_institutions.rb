class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :name
      t.string :description
      t.string :country
      t.string :city
      t.string :logo

      t.timestamps null: false
    end
  end
end
