# table for working hours
class CreateReflectionsTable < ActiveRecord::Migration[7.0]
    def change
      create_table :reflections do |entry|
        entry.datetime :created_at
      end
    end
  end