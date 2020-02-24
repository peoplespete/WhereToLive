class AddPrecipitationAndTemperatureMinAndTemperatureMaxToPlaces < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :precipitation, :decimal
    add_column :places, :temperature_min, :integer
    add_column :places, :temperature_max, :integer
  end
end
