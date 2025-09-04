class CarbonCalculatorService
  def initialize(route)
    @route = route
    @carbon_api = CarbonInterfaceService.new
  end
end

