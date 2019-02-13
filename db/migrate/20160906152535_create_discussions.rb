class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.references :discussable, polymorphic: true
      t.references :user
      t.string :field_name
      t.text :context

      t.timestamps null: false
    end

    add_index :discussions, [:discussable_type, :discussable_id]
  end
end
