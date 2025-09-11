class ClimatiqService
  include HTTParty
  base_uri "https://api.climatiq.io"

  def initialize
    @api_key = ENV["CLIMATIQ_API_KEY"]
    @headers = {
      'Authorization' => "Bearer #{@api_key}",
      'Content-Type' => "application/json"
    }
  end

  def calculate_transport_emissions(transport_method, distance_km)
    factor = get_emission_factor(transport_method)

    # Cas spécial zéro émission
    return { carbon_kg: 0, factor_kg_per_km: 0, uncertainty_percentage: 0 } if factor.nil?

    body = {
      emission_factor: {
        activity_id: factor,
        data_version: "25.25"
      },
      parameters: {
        distance: distance_km,
        distance_unit: "km"
      }
    }

    response = self.class.post("/estimate", {
      body: body.to_json,
      headers: @headers
    })

    if response.success?
      data = response.parsed_response['co2e']

      {
        carbon_kg: data,
        factor_kg_per_km: data / distance_km,
        uncertainty_percentage: 5 # Climatiq fournit souvent des valeurs fiables
      }
    else
      raise "Climatiq API Error: #{response.body}"
    end
  end

  private

  def get_emission_factor(transport_method)
    # Documentation : https://www.climatiq.io/docs/api-reference
    mapping = {
      'Car' => 'passenger_vehicle-vehicle_type_car-fuel_source_na-engine_size_na-vehicle_age_na-vehicle_weight_na',
      'Bus' => 'passenger_vehicle-vehicle_type_bus-fuel_source_na-engine_size_na-vehicle_age_na-vehicle_weight_na',
      'Train' => 'passenger_vehicle-vehicle_type_train-fuel_source_na-engine_size_na-vehicle_age_na-vehicle_weight_na',
      'Flight'  => 'passenger_flight-route_type_na-aircraft_type_na-distance_short_medium_haul_lt_1000km-class_na-rf_included-distance_uplift_na',
      'Bicycle' => nil,
      'Walking' => nil
    }

    mapping[transport_method.name]
  end
end