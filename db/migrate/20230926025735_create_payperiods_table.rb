class CreatePayperiodsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :payperiods do |entry| 
      entry.integer :time
    end
  end
end