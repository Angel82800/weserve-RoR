class AddPriorityToBoard < ActiveRecord::Migration
  def change
    add_column :boards, :priority, :integer, default: 0
  end
end
