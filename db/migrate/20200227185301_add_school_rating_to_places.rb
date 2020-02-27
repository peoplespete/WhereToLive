class AddSchoolRatingToPlaces < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :school_rating, :decimal
  end
end
