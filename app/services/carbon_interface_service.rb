class CarbonInterfaceService
  include HTTParty
  base_uri "https://www.carboninterface.com/api/v1/estimates"

  def initialize
    @api_key = ENV["CARBON_INTERFACE_API_KEY"]
    @headers = {
      'Authorization' => "Bearer #{@api_key}",
      'Content-Type' => "application/json"
    }
  end