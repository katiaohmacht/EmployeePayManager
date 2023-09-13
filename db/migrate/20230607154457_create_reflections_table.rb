class CreateReflectionsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :reflections do |entry|
      entry.string :rgb
      entry.string :summary
      entry.datetime :created_at
      entry.integer :user_id
    end
  end
end
