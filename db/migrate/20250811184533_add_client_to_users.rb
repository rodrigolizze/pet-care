class AddClientToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :client, :boolean, default: true, null: false
  end
end
