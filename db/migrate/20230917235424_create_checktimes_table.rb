class CreateChecktimesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :checktimes do |entry|
      entry.integer :employee_id
      entry.integer :time
      entry.boolean :out
    end
  end
end
