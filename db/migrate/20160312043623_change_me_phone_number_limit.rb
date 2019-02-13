class ChangeMePhoneNumberLimit < ActiveRecord::Migration
  def change
  
  	add_column :users, :phone_number, :string, :limit =>8
  end
end
