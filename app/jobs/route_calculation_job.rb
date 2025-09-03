class RouteCalculationJob < ApplicationJob
  queue_as :default

  def perform(journey_id)
    journey = Journey.find(journey_id)
    RouteFinderService.new(journey).find_all_routes
  rescue StandardError => e
    Rails.logger.error "Carbon calculation failed for journey #{journey_id}: #{e.message}"
  end
end
