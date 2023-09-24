class CreateUsersTable < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |entry|
      entry.string :password_hash
      entry.string :password
      entry.boolean :admin
      entry.string :job
      entry.integer :salary
      entry.string :employee_id
      entry.string :address
      entry.string :first_name
      entry.string :last_name
      # one for hourly, 0 for salary
      entry.integer :hourly 
      entry.datetime :created_at
      entry.datetime :updated_at
    end
  end
end
