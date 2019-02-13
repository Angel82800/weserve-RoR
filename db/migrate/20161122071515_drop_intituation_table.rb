class DropIntituationTable < ActiveRecord::Migration
  def change
    def up
      drop_table :institution_users, :force => true
      drop_table :institutions,:force => true
    end

    def down
      fail ActiveRecord::IrreversibleMigration
    end
  end
end
