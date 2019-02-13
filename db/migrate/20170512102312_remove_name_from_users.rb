class RemoveNameFromUsers < ActiveRecord::Migration
  def change
    User.all.each do |user|
      next unless (user.first_name.blank? && user.last_name.blank?)
      user.first_name = user.name.split(' ').first
      user.last_name = user.name.split(' ').second
      user.save
     end
    remove_column :users, :name, :string
  end
end
