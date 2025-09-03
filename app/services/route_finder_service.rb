class RouteFinderService
  def initialize(journey)
    @journey = journey
    # @mapbox = MapboxService.new
  end

  def find_all_routes
    routes = []

    # Get different routes for each transport option

    routes << find_walking_route
    # routes << find_cycling_route
    # routes << find_driving_route
    # routes << find_flying_route

    # routes.compact.each do |route|
    #   CarbonCalculationJob.perform_later(route.id)
    # end

    routes.compact
  end

  private

  def find_walking_route
    # directions_data = @mapbox.directions(
    #   origin: [@journey.origin_lat, @journey.origin_lng],
    #   destination: [@journey.destination_lat, @journey.destination_lng],
    #   profile: 'walking'
    # )

    # return nil unless directions_data

    walking_mode = TransportMode.find_by(name: 'Walking')

    @journey.routes.create!(
      transport_mode: walking_mode,
      total_duration_minutes: 2,
      total_distance_km: 4,
      eco_score: 3
      # total_duration_minutes: directions_data[:duration_minutes],
      # total_distance_km: directions_data[:distance_km],
      # map_polyline: directions_data[:polyline]
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create walking route: #{e.message}"
    nil
  end
end


