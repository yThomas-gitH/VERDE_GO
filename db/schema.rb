# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_28_130009) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "carbon_calculations", force: :cascade do |t|
    t.bigint "route_id", null: false
    t.decimal "total_emissions_kg", precision: 8, scale: 4
    t.decimal "carbon_saved_kg", precision: 8, scale: 4, default: "0.0"
    t.string "calculation_method"
    t.json "breakdown"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_carbon_calculations_on_route_id"
  end

  create_table "journeys", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "origin_address", null: false
    t.string "destination_address", null: false
    t.decimal "origin_lat", precision: 10, scale: 6
    t.decimal "origin_lng", precision: 10, scale: 6
    t.decimal "destination_lat", precision: 10, scale: 6
    t.decimal "destination_lng", precision: 10, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_journeys_on_user_id"
  end

  create_table "routes", force: :cascade do |t|
    t.bigint "journey_id", null: false
    t.bigint "transport_mode_id", null: false
    t.integer "total_duration_minutes"
    t.decimal "total_distance_km", precision: 8, scale: 3
    t.integer "eco_score"
    t.json "map_polyline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["journey_id"], name: "index_routes_on_journey_id"
    t.index ["transport_mode_id"], name: "index_routes_on_transport_mode_id"
  end

  create_table "transport_modes", force: :cascade do |t|
    t.string "name", null: false
    t.string "icon_name"
    t.decimal "carbon_factor_kg_per_km", precision: 6, scale: 4
    t.string "color_hex", default: "#000000"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "carbon_calculations", "routes"
  add_foreign_key "journeys", "users"
  add_foreign_key "routes", "journeys"
  add_foreign_key "routes", "transport_modes"
end
