class CarbonCalculation < ApplicationRecord
  belongs_to :route
  
  validates :total_emissions_kg, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def emissions_per_km
    return 0 if route.total_distance_km.zero?
    total_emissions_kg / route.total_distance_km
  end

  def equivalent_trees_needed
    # Average tree absorbs ~25 kg CO2 per year
    # https://ecotree.green/combien-de-co2-absorbe-un-arbre#:~:text=est%20plus%20importante.-,Un%20arbre%20absorbe%20environ%2025%20kg%20de%20CO2%20par,par%20arbre%20et%20par%20an.
    (total_emissions_kg / 25).ceil #rounded at upper integer
end
