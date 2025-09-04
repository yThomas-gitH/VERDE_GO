class MapboxService
  include HTTParty
  base_uri 'https://api.mapbox.com'

  def initialize
    @access_token = ENV["MAPBOX_ACCESS_TOKEN"]
  end

  def directions(origin:, destination:, profile: 'driving')

    coordinates = "#{origin[1]},#{origin[0]};#{destination[1]},#{destination[0]}"

    response = self.class.get("/directions/v5/mapbox/#{profile}/#{coordinates}", {
      query: {
        access_token: @access_token,
        geometries: 'polyline'
        # overview: 'full'
      }
    })

    if response.success? && response['routes']&.any?
      route_data = response['routes'].first

      {
        duration_minutes: (route_data['duration'] / 60).round,
        distance_km: (route_data['distance'] / 1000).round(3),
        polyline: route_data['geometry'],
      }
    else
      Rails.logger.error "Mapbox API Error: #{response.body}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Mapbox Service Error: #{e.message}"
    nil
  end
end

