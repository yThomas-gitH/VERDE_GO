class TransportMode < ApplicationRecord
  has_many :routes
  
  validates :name, presence: true, uniqueness: true
  validates :carbon_factor_kg_per_km, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :zero_emission, -> { where(carbon_factor_kg_per_km: 0) }
  scope :low_emission, -> { where('carbon_factor_kg_per_km < ?', 0.1) }

  DEFAULT_FACTORS = {
    'Walking' => 0.0,
    'Bicycle' => 0.0,
    'Bus' => 0.08891,     # kg CO2e par km par passager
    'Train' => 0.04115,   # kg CO2e par km par passager  
    'Car' => 0.17141,     # kg CO2e par km (voiture moyenne)
    'Flight' => 2.0,    # kg CO2e par km
  }.freeze

end
