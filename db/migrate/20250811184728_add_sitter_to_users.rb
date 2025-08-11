class AddSitterToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :sitter, :boolean, default: false, null: false
  end
end
