class JourneysController < ApplicationController
  # before_action :require_login
  before_action :set_journey, only: [:destroy]
  
  def index
    @journeys = current_user.journeys.recent.includes(routes: [:carbon_calculation, :transport_mode]) || []
    @journey = Journey.new(user: current_user) # For the new journey form on index page
    
    respond_to do |format|
      format.html
      format.json { 
        render json: {
          journeys: @journeys.as_json(
            include: {
              routes: {
                include: [:carbon_calculation, :transport_mode],
                methods: [:carbon_per_km]
              }
            },
            methods: [:distance_km]
          )
        }
      }
    end
  end
  
  def new
    @journey = Journey.new(user: current_user)
    
    respond_to do |format|
      format.html
      format.json { render json: { journey: @journey } }
    end
  end
  
  def create
    @journey = Journey.new(journey_params)
    @journey.user = current_user

    # Geocode the addresses before saving
    if geocode_addresses
      if @journey.save
        respond_to do |format|
          format.html { 
            redirect_to journey_routes_path(@journey), 
            notice: 'Journey created! We\'re calculating the best routes for you...' 
          }
          format.json { 
            render json: { 
              journey: @journey.as_json(methods: [:distance_km]),
              message: 'Journey created successfully. Routes are being calculated.',
              redirect_url: journey_routes_path(@journey)
            }, status: :created 
          }
        end

        RouteCalculationJob.perform_later(@journey.id)

      else
        respond_to do |format|
          format.html { 
            @journeys = current_user.journeys.recent.includes(routes: [:carbon_calculation, :transport_mode])
            render :index, status: :unprocessable_entity 
          }
          format.json { 
            render json: { 
              errors: @journey.errors.full_messages,
              journey: @journey
            }, status: :unprocessable_entity 
          }
        end
      end
    else
      # Geocoding failed
      @journey.errors.add(:base, 'Could not find the specified addresses. Please check and try again.')
      respond_to do |format|
        format.html { 
          @journeys = current_user.journeys.recent.includes(routes: [:carbon_calculation, :transport_mode])
          render :index, status: :unprocessable_entity 
        }
        format.json { 
          render json: { 
            errors: @journey.errors.full_messages,
            journey: @journey
          }, status: :unprocessable_entity 
        }
      end
    end
  end
  
  def destroy
    journey_id = @journey.id
    @journey.destroy
    
    respond_to do |format|
      format.html { redirect_to journeys_path, notice: 'Journey deleted successfully.' }
      format.json { 
        render json: { 
          message: 'Journey deleted successfully.',
          deleted_journey_id: journey_id
        }
      }
    end
  end
  
  # AJAX endpoint to check route calculation status
  def route_status
    @journey = current_user.journeys.find(params[:id])
    routes = @journey.routes.includes(:carbon_calculation, :transport_mode)
    routes_with_carbon = routes.joins(:carbon_calculation)
    
    status = if routes.empty?
               'calculating_routes'
             elsif routes_with_carbon.count < routes.count
               'calculating_carbon'
             else
               'complete'
             end
    
    render json: { 
      status: status,
      routes_count: routes.count,
      routes_with_carbon_count: routes_with_carbon.count,
      routes: routes.as_json(
        include: [:carbon_calculation, :transport_mode],
        methods: [:carbon_per_km]
      ),
      journey: @journey.as_json(methods: [:distance_km]),
      progress_percentage: calculate_progress_percentage(routes.count, routes_with_carbon.count)
    }
  end
  
  private
  
  def set_journey
    @journey = current_user.journeys.find(params[:id])
  end
  
  def journey_params
    params.require(:journey).permit(
      :origin_address, :destination_address
    )
  end
  
  def geocode_addresses
    return false if @journey.origin_address.blank? || @journey.destination_address.blank?
    begin
      # Geocode origin
      origin_coords = Geocoder.coordinates(@journey.origin_address)
      return false unless origin_coords
      
      @journey.origin_lat = origin_coords[0]
      @journey.origin_lng = origin_coords[1]
      
      # Geocode destination
      destination_coords = Geocoder.coordinates(@journey.destination_address)
      return false unless destination_coords
      
      @journey.destination_lat = destination_coords[0]
      @journey.destination_lng = destination_coords[1]
      
      true
    rescue StandardError => e
      Rails.logger.error "Geocoding failed: #{e.message}"
      false
    end
  end
  
  def calculate_progress_percentage(routes_count, routes_with_carbon_count)
    return 0 if routes_count.zero?
    
    # 50% for route calculation, 50% for carbon calculation
    route_progress = routes_count > 0 ? 50 : 0
    carbon_progress = (routes_with_carbon_count.to_f / routes_count * 50).round
    
    route_progress + carbon_progress
  end
  
  def calculate_car_baseline
    return nil unless @journey
    
    car_route = @journey.routes.joins(:transport_mode)
                        .where(transport_modes: { name: 'car' })
                        .first
    
    if car_route&.carbon_calculation
      {
        emissions_kg: car_route.carbon_calculation.total_emissions_kg,
        duration_minutes: car_route.total_duration_minutes,
        distance_km: car_route.total_distance_km
      }
    else
      # Fallback calculation
      distance = @journey.distance_km
      {
        emissions_kg: distance * 0.171, # Average car emissions
        duration_minutes: (distance / 50.0 * 60).round, # Assume 50 km/h average
        distance_km: distance
      }
    end
  end
end