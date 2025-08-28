class TransportMode < ApplicationRecord
  has_many :routes
  
  validates :name, presence: true, uniqueness: true
  validates :carbon_factor_kg_per_km, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :zero_emission, -> { where(carbon_factor_kg_per_km: 0) }
  scope :low_emission, -> { where('carbon_factor_kg_per_km < ?', 0.1) }
end
