class PlacesController < ApplicationController

  def index
    @population = {
      min: Place.minimum('population'),
      max: Place.maximum('population'),
    }
    @home_price = {
      min: Place.minimum('home_price'),
      max: Place.maximum('home_price'),
    }

    @q = Place.ransack(params[:q])
    @places = @q.result(distinct: true)
  end

end
