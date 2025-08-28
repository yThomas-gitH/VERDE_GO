class CreateCarbonCalculations < ActiveRecord::Migration[8.0]
  def change
    create_table :carbon_calculations do |t|
      t.references :route, null: false, foreign_key: true
      t.decimal :total_emissions_kg, precision: 8, scale: 4
      t.decimal :carbon_saved_kg, precision: 8, scale: 4, default: 0
      t.string :calculation_method
      t.json :breakdown # Store per-segment calculations
      t.timestamps
    end
  end
end
