class CreateTransportModes < ActiveRecord::Migration[8.0]
  def change
    create_table :transport_modes do |t|
      t.string :name, null: false
      t.string :icon_name
      t.decimal :carbon_factor_kg_per_km, precision: 6, scale: 4
      t.string :color_hex, default: '#000000'
      t.timestamps
    end
  end
end
