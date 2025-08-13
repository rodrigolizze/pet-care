class AddGroupTokenToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :group_token, :string
    add_index  :bookings, :group_token
  end
end
