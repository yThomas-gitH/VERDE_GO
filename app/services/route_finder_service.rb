class RouteFinderService
  def initialize(journey)
    @journey = journey
    @mapbox = MapboxService.new
  end

  def find_all_routes
    routes = []

    # Get different routes for each transport option

    routes << find_walking_route
    routes << find_cycling_route
    driving_route = find_driving_route
    routes << driving_route
    routes << find_bus_route(driving_route)
    routes << find_train_route
    routes << find_flying_route

    # routes.compact.each do |route|
    #   CarbonCalculationJob.perform_later(route.id)
    # end
    CarbonCalculationJob.perform_later(routes[2].id)

    routes.compact
  end

  private

  def find_walking_route
    directions_data = @mapbox.directions(
      origin: [@journey.origin_lat, @journey.origin_lng],
      destination: [@journey.destination_lat, @journey.destination_lng],
      profile: 'walking'
    )

    return nil unless directions_data

    walking_mode = TransportMode.find_by(name: 'Walking')

    @journey.routes.create!(
      transport_mode: walking_mode,
      total_duration_minutes: directions_data[:duration_minutes],
      total_distance_km: directions_data[:distance_km],
      map_polyline: directions_data[:polyline],
      eco_score: 10
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create walking route: #{e.message}"
    nil
  end

  def find_cycling_route
    directions_data = @mapbox.directions(
      origin: [@journey.origin_lat, @journey.origin_lng],
      destination: [@journey.destination_lat, @journey.destination_lng],
      profile: 'cycling'
    )

    return nil unless directions_data

    cycling_mode = TransportMode.find_by(name: "Bicycle")

    @journey.routes.create!(
      transport_mode: cycling_mode,
      total_duration_minutes: directions_data[:duration_minutes],
      total_distance_km: directions_data[:distance_km],
      map_polyline: directions_data[:polyline],
      eco_score: 9
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create cycling route: #{e.message}"
    nil
  end

  def find_driving_route
    directions_data = @mapbox.directions(
      origin: [@journey.origin_lat, @journey.origin_lng],
      destination: [@journey.destination_lat, @journey.destination_lng],
      profile: 'driving'
    )

    return nil unless directions_data

    driving_mode = TransportMode.find_by(name: 'Car')

    @journey.routes.create!(
      transport_mode: driving_mode,
      total_duration_minutes: directions_data[:duration_minutes],
      total_distance_km: directions_data[:distance_km],
      map_polyline: directions_data[:polyline],
      eco_score: 3
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create driving route: #{e.message}"
    nil
  end

  def find_bus_route(car_data)
    directions_data = car_data

    return nil unless directions_data

    bus_mode = TransportMode.find_by(name: 'Bus')

    @journey.routes.create!(
      transport_mode: bus_mode,
      total_duration_minutes: directions_data[:total_duration_minutes],
      total_distance_km: directions_data[:total_distance_km],
      map_polyline: directions_data[:map_polyline],
      eco_score: 6
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create bus route: #{e.message}"
    nil
  end

  def find_train_route

    train_mode = TransportMode.find_by(name: 'Train')

    # Average train speed set to 70km/h
    avg_train_speed = 70.0
    bird_distance = @journey.distance_km
    train_duration = 60 / avg_train_speed * bird_distance

    return nil unless bird_distance

    @journey.routes.create!(
      transport_mode: train_mode,
      total_duration_minutes: train_duration,
      total_distance_km: @journey.distance_km,
      map_polyline: "//",
      eco_score: 8
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create train route: #{e.message}"
    nil
  end

  def find_flying_route

    flying_mode = TransportMode.find_by(name: 'Flying')

    # Average commercial plane speed set to 900km/h
    avg_plane_speed = 900.0
    bird_distance = @journey.distance_km
    flight_duration = 60 / avg_plane_speed * bird_distance

    return nil unless bird_distance

    @journey.routes.create!(
      transport_mode: flying_mode,
      total_duration_minutes: flight_duration,
      total_distance_km: @journey.distance_km,
      map_polyline: "//",
      eco_score: 0
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create plane route: #{e.message}"
    nil
  end
  
end


