class CreateRoutes < ActiveRecord::Migration[8.0]
  def change
    create_table :routes do |t|
      t.references :journey, null: false, foreign_key: true
      t.references :transport_mode, null: false, foreign_key: true
      t.integer :total_duration_minutes
      t.decimal :total_distance_km, precision: 8, scale: 3
      t.integer :eco_score # 1-10 scale
      t.json :map_polyline # Encoded polyline from Maps API
      t.timestamps
    end
  end
end