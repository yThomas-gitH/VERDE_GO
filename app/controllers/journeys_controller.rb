class JourneysController < ApplicationController

  def index
    @journeys = current_user.journeys.recent
  end
end
