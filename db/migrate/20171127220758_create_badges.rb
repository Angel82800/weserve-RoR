class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.integer :badge_type
      t.references :user, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
