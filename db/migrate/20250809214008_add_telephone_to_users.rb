class AddTelephoneToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :telephone, :string
  end
end
