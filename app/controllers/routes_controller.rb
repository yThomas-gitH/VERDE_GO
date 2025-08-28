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
      format.json { render json: @routes.as_json(include: [:carbon_calculation, :transport_mode]) }
    end
  end
  
  def show
    @route = current_user.routes.find(params[:id])
    @carbon_calculation = @route.carbon_calculation
    @transport_mode = @route.transport_mode
  end
  
  def create
    @journey = current_user.journeys.find(params[:journey_id])
    
    # This would typically be called by RouteFinderService
    routes = RouteFinderService.new(@journey).find_all_routes
    
    render json: { routes: routes, journey: @journey }
  end
end
