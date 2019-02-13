class AddPreferredLanguageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :preferred_language, :string, :default => 'en'
  end
end
