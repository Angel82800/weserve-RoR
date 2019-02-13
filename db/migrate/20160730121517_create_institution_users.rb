class CreateInstitutionUsers < ActiveRecord::Migration
  def change
    create_table :institution_users do |t|
      t.references :institution, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :position

      t.timestamps null: false
    end
  end
end
