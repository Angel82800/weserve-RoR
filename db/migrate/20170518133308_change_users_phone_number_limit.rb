class ChangeUsersPhoneNumberLimit < ActiveRecord::Migration
  def change
    change_column :users, :phone_number, :string, :limit => 15
  end
end
