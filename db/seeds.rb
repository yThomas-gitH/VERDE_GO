# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


puts "Cleaning database..."
CarbonCalculation.destroy_all
Route.destroy_all
Journey.destroy_all
TransportMode.destroy_all
User.destroy_all

puts "Creating users..."
user1 = User.create!(email: "yann@test.test", password: "123456")
user2 = User.create!(email: "bob@example.com", password: "password")

puts "Creating transport modes..."
car = TransportMode.create!(name: "Car", icon_name: "car", carbon_factor_kg_per_km: 0.192, color_hex: "#FF5733")
bus = TransportMode.create!(name: "Bus", icon_name: "bus", carbon_factor_kg_per_km: 0.089, color_hex: "#33C1FF")
train = TransportMode.create!(name: "Train", icon_name: "train", carbon_factor_kg_per_km: 0.041, color_hex: "#33FF77")
bike = TransportMode.create!(name: "Bicycle", icon_name: "bicycle", carbon_factor_kg_per_km: 0.0, color_hex: "#FFD700")
walk = TransportMode.create!(name: "Walking", icon_name: "walking", carbon_factor_kg_per_km: 0.0, color_hex: "#A9A9A9")
plane = TransportMode.create!(name: "Flying", icon_name: "flying", carbon_factor_kg_per_km: 0.0, color_hex: "#A9A9A9")

puts "Creating journeys..."
journey1 = Journey.create!(
  user: user1,
  origin_address: "Brussels, Belgium",
  destination_address: "Antwerp, Belgium",
  origin_lat: 50.8503,
  origin_lng: 4.3517,
  destination_lat: 51.2194,
  destination_lng: 4.4025
)

journey2 = Journey.create!(
  user: user2,
  origin_address: "Liège, Belgium",
  destination_address: "Namur, Belgium",
  origin_lat: 50.6333,
  origin_lng: 5.5667,
  destination_lat: 50.4669,
  destination_lng: 4.8675
)

puts "Creating routes for journey1..."
route_car = Route.create!(
  journey: journey1,
  transport_mode: car,
  total_duration_minutes: 55,
  total_distance_km: 44.8,
  eco_score: 3,
  map_polyline: { path: "polyline_data_here" }
)

route_train = Route.create!(
  journey: journey1,
  transport_mode: train,
  total_duration_minutes: 60,
  total_distance_km: 44.8,
  eco_score: 7,
  map_polyline: { path: "polyline_data_here" }
)

puts "Adding carbon calculations..."
CarbonCalculation.create!(
  route: route_car,
  total_emissions_kg: route_car.total_distance_km * car.carbon_factor_kg_per_km,
  carbon_saved_kg: 0,
  calculation_method: "factor_based",
  breakdown: { fuel: "petrol" }
)

CarbonCalculation.create!(
  route: route_train,
  total_emissions_kg: route_train.total_distance_km * train.carbon_factor_kg_per_km,
  carbon_saved_kg: (route_car.total_distance_km * car.carbon_factor_kg_per_km) - (route_train.total_distance_km * train.carbon_factor_kg_per_km),
  calculation_method: "factor_based",
  breakdown: { electricity: "green mix" }
)

puts "Seeding done!"