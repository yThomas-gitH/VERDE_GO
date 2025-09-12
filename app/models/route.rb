class Route < ApplicationRecord
  belongs_to :journey
  belongs_to :transport_mode
  has_one :carbon_calculation, dependent: :destroy

  validates :total_duration_minutes, :total_distance_km, presence: true
  validates :eco_score, presence: true, inclusion: { in: 0..10 }

  scope :by_eco_score, -> { order(eco_score: :desc) }
  scope :by_duration, -> { order(:total_duration_minutes) }
  scope :by_carbon, -> { joins(:carbon_calculation).order('carbon_calculations.total_emissions_kg ASC') }

  def carbon_per_km
    return 0 if total_distance_km.zero?
    carbon_calculation&.total_emissions_kg&./(total_distance_km) || 0
  end

  def carbon_emissions_kg
    total_distance_km * transport_mode.carbon_factor_kg_per_km #pas certain vu qu'utilisation d'API
  end
end
