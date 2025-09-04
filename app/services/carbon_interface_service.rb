class CarbonInterfaceService
  include HTTParty
  base_uri "https://www.carboninterface.com/api/v1"

  def initialize
    @api_key = ENV["CARBON_INTERFACE_API_KEY"]
    @headers = {
      'Authorization' => "Bearer #{@api_key}",
      'Content-Type' => "application/json"
    }
  end

  def calculate_transport_emissions(transport_method:, distance_km:, passengers: 1)
    body = {
      type: 'vehicle',
      distance_unit: 'km',
      distance_value: distance_km,
      vehicle_model_id: get_vehicle_model_id(transport_method),
      passengers: passengers
    }

    response = self.class.post('/estimates', {
      body: body.to_json,
      headers: @headers
    })

    if response.success?
      data = response.parsed_response['data']['attributes']

      {
        carbon_kg: data['carbon_kg'],
        factor_kg_per_km: data['carbon_kg'] / distance_km,
        uncertainty_percentage: 10
      }
    else
      raise "Carbon API Error: #{response.body}"
    end
  end

  private
    
    def get_vehicle_model_id(transport_method)
      # These would be actual model IDs from the CarbonInterface API
      vehicle_mapping = {
        'car' => 'a4d0c965-a1eb-4650-bb4c-3d5d7b228c06', # Average car
        'bus' => 'b2f4c123-b9eb-4650-cc4c-4e6e8c229d07', # City bus
        'train' => 'c5f5d234-c0fc-4750-dd5d-5f7f9d330e08', # Passenger train
        'bicycle' => nil, # Zero emissions
        'walking' => nil, # Zero emissions
        'taxi' => 'a4d0c965-a1eb-4650-bb4c-3d5d7b228c06' # Same as car
      }
      
      # Return zero emissions for walking/cycling
      return handle_zero_emissions(transport_method) if vehicle_mapping[transport_method].nil?
      
      vehicle_mapping[transport_method]
    end
    
    def handle_zero_emissions(transport_method)
      # For walking/cycling, return zero emissions
      if ['walking', 'bicycle'].include?(transport_method)
        return :zero_emissions
      end
      
      # Fallback to average car
      'a4d0c965-a1eb-4650-bb4c-3d5d7b228c06'
    end
  end