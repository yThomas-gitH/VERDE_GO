class CreateJourneys < ActiveRecord::Migration[8.0]
  def change
    create_table :journeys do |t|
      t.references :user, null: false, foreign_key: true
      t.string :origin_address, null: false
      t.string :destination_address, null: false
      t.decimal :origin_lat, precision: 10, scale: 6
      t.decimal :origin_lng, precision: 10, scale: 6
      t.decimal :destination_lat, precision: 10, scale: 6
      t.decimal :destination_lng, precision: 10, scale: 6
      t.timestamps
    end
  end
end
