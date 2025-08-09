class AddBioAndExperienceToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :bio, :text
    add_column :users, :experience, :text
  end
end
