class AddFilesToTasks < ActiveRecord::Migration
  def change
  	add_column :tasks, :fileone, :string
  	add_column :tasks, :filetwo, :string
  	add_column :tasks, :filethree, :string
  	add_column :tasks, :filefour, :string
  	add_column :tasks, :filefive, :string
  end
end
