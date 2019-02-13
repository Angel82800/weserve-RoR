class AddAttachementToMessages < ActiveRecord::Migration
  def change
    add_column :group_messages, :attachment, :string
  end
end
