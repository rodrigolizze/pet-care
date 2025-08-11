class AddUserPreferencesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :property_type, :string
    add_column :users, :backyard, :boolean, default: false, null: false
    add_column :users, :has_pet, :boolean, default: false, null: false
    add_column :users, :screened_windows, :boolean, default: false, null: false
    add_column :users, :animal_sizes, :string
  end
end
