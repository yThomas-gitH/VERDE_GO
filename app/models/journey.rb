class Journey < ApplicationRecord
  belongs_to :user
  has_many :routes, dependent: :destroy

  validates :origin_address, :destination_address, presence: true
  validates :origin_lat, :origin_lng, :destination_lat, :destination_lng, presence: true, numericality: true

  geocoded_by :origin_address, latitude: :origin_lat, longitude: :origin_lng
  reverse_geocoded_by :destination_lat, :destination_lng, address: :destination_address

  scope :recent, -> { order(created_at: :desc) }

  def distance_km
    Geocoder::Calculations.distance_between(
      [origin_lat, origin_lng], 
      [destination_lat, destination_lng]
    )
  end

  def best_eco_route
    routes.joins(:carbon_calculation)
          .order('carbon_calculations.total_emissions_kg ASC')
          .first
  end

end
