class Journey < ApplicationRecord
  belongs_to :user
  has_many :routes, dependent: :destroy

  validates :origin_address, :destination_address, presence: true
  validates :origin_lat, :origin_lng, :destination_lat, :destination_lng, presence: true, numericality: true

  geocoded_by :origin_address, latitude: :origin_lat, longitude: :origin_lng
  geocoded_by :destination_address, latitude: :destination_lat, longitude: :destination_lng

  after_validation :geocode, if: ->(journey){ journey.origin_address.present? and journey.destination_address.present? }

  scope :recent, -> { order(created_at: :desc) }

  # after_create :calculate_routes

  def distance_km
    Geocoder::Calculations.distance_between( [origin_lat, origin_lng], [destination_lat, destination_lng] ) / 0.621371 # Conversion from miles to km
  end

  def best_eco_route
    routes.joins(:carbon_calculation)
          .order('carbon_calculations.total_emissions_kg ASC')
          .first
  end

  private

  def calculate_routes
    RouteCalculationJob.perform_later(id)
  end

end
