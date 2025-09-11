class CarbonCalculatorService
  def initialize(route)
    @route = route
    @carbon_api = ClimatiqService.new
  end

  def calculate!
    car_baseline = 0
    begin
      climatiq_calculation = calculate_with_climatiq
      car_baseline = climatiq_calculation[:baseline_car_emissions]
      save_calculation(climatiq_calculation)
    rescue StandardError => e
      Rails.logger.warn "Calcul Climatiq échoué: #{e.message}"
      nil
    end
    
    # Mise à jour du score écologique
    carbon_calc = @route.carbon_calculation
    @route.update!(eco_score: calculate_eco_score(carbon_calc.total_emissions_kg, car_baseline))

  end

  private
  
  def calculate_with_climatiq
    
    # Appel de l'API Climatiq pour des calculs précis
    api_response = @carbon_api.calculate_transport_emissions(@route.transport_mode, @route.total_distance_km)
    # @route.total_distance_km
    
    emissions = api_response[:carbon_kg]
    
    # Calcul du baseline voiture pour comparaison
    car_mode = TransportMode.find_by(name: 'car')
    car_baseline = if car_mode
                     @climatiq.calculate_transport_emissions(
                       transport_mode: car_mode,
                       distance_km: @route.total_distance_km
                     )[:carbon_kg]
                   else
                     @route.total_distance_km * 0.17141 # Fallback
                   end
    
    {
      total_emissions: emissions,
      carbon_saved: [car_baseline - emissions, 0].max,
      baseline_car_emissions: car_baseline,
      climatiq_activity_id: api_response[:activity_id],
      emission_factor_source: api_response[:source],
      emission_factor_year: api_response[:year],
      uncertainty_percentage: api_response[:uncertainty_percentage],
      api_response: api_response[:api_response]
    }
  end

  def save_calculation(carbon_data)
    CarbonCalculation.create!(
      route: @route,
      total_emissions_kg: carbon_data[:total_emissions],
      carbon_saved_kg: carbon_data[:carbon_saved],
      calculation_method: 'distance_based'
    )
  end
  
  def calculate_eco_score(actual_emissions, baseline_car)
    car_baseline = baseline_car
    
    return 10 if actual_emissions.zero?
    
    # Ratio par rapport à la voiture
    ratio = actual_emissions / car_baseline
    
    score = case ratio
            when 0..0.05 then 10    # 95%+ de réduction
            when 0.05..0.15 then 9  # 85-95% de réduction
            when 0.15..0.30 then 8  # 70-85% de réduction
            when 0.30..0.50 then 7  # 50-70% de réduction
            when 0.50..0.70 then 6  # 30-50% de réduction
            when 0.70..0.85 then 5  # 15-30% de réduction
            when 0.85..1.00 then 4  # 0-15% de réduction
            when 1.00..1.15 then 3  # 0-15% d'augmentation
            when 1.15..1.30 then 2  # 15-30% d'augmentation
            else 1                  # 30%+ d'augmentation
            end
    
    score.clamp(1, 10)
  end
end

