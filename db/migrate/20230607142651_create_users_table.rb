class CreateUsersTable < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |entry|
      entry.string :id
      entry.string :password_hash
      entry.string :first_name
      entry.string :last_name
      entry.datetime :created_at
      entry.datetime :updated_at
    end
  end
end
