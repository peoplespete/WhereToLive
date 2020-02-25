class AddHoursToWinstonAndHoursToPhillyToPlaces < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :hours_to_winston, :decimal
    add_column :places, :hours_to_philly, :decimal
  end
end
