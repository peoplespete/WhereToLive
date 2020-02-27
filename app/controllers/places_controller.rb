class PlacesController < ApplicationController

  def index
    @population_density = {
      min: Place.minimum('population_density'),
      max: Place.maximum('population_density'),
    }
    @home_price = {
      min: Place.minimum('home_price'),
      max: Place.maximum('home_price'),
    }

    @q = Place.ransack(params[:q])
    @places = @q.result(distinct: true)
  end

end
