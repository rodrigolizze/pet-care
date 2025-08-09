class MakeAvailabilityIdUniqueOnBookings < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # Remove existing non-unique index if present
    if index_exists?(:bookings, :availability_id, unique: false)
      remove_index :bookings, :availability_id
    end

    # Add unique index (skip if it already exists)
    unless index_exists?(:bookings, :availability_id, unique: true)
      add_index :bookings, :availability_id, unique: true, algorithm: :concurrently
    end
  end

  def down
    # Remove unique index
    if index_exists?(:bookings, :availability_id, unique: true)
      remove_index :bookings, column: :availability_id, algorithm: :concurrently
    end

    # Recreate non-unique index (optional)
    unless index_exists?(:bookings, :availability_id, unique: false)
      add_index :bookings, :availability_id, algorithm: :concurrently
    end
  end
end
