class RoutesController < ApplicationController
  # before_action :require_login
  
  def index
    @journey = current_user.journeys.find(params[:journey_id])
    @routes = @journey.routes.includes(:carbon_calculation, :transport_mode)
    
    # Sort by user preference
    case params[:sort]
    when 'eco'
      @routes = @routes.by_eco_score
    when 'time'
      @routes = @routes.by_duration
    when 'carbon'
      @routes = @routes.by_carbon
    else
      @routes = @routes.by_eco_score
    end
    
    respond_to do |format|
      format.html
      format.json do
        render json: {
          routes: @routes.as_json(
            include: [:carbon_calculation, :transport_mode],
            methods: [:carbon_per_km]
          )
        }
      end
    end
  end
  
  def show
    @journey = current_user.journeys.find(params[:journey_id])
    @route = current_user.routes.find(params[:id])
    @carbon_calculation = @route.carbon_calculation
    @transport_mode = @route.transport_mode

    respond_to do |format|
      format.html
      format.json { 
        render json: @route.as_json(
          include: [:carbon_calculation, :transport_mode],
          methods: [:carbon_per_km]
        )
      }
    end
  end
  
  def recalculate
    @journey = current_user.journeys.find(params[:journey_id])
    @journey.routes.destroy_all
    RouteCalculationJob.perform_later(@journey.id)

    render json: { message: 'Route recalculation started' }
  end
end
