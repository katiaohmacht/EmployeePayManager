class CreateDrawingsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :drawings do |entry|
      entry.string :name
      entry.string :path
      entry.datetime :created_at
      entry.datetime :updated_at
      entry.integer :user_id
      entry.string :rgb
    end
  end
end
