class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :availability, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :pet_name
      t.string :animal_type
      t.string :pet_size
      t.integer :pet_birth_year

      t.timestamps
    end
  end
end
