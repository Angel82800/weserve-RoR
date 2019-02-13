class AddApplicationToDoForFrees < ActiveRecord::Migration
  def change
    add_column :do_for_frees, :application, :text
  end
end
