class CarbonCalculationJob < ApplicationJob
  queue_as :default

  def perform(route_id)
    route = Route.find(route_id)
    CarbonCalculatorService.new(route).calculate!
  rescue StarndardError => e
    Rails.logger.error "Carbon calculation failed for route #{route_id}: #{e.message}"
  end
end
