class AddsPopulationAndPopulationDensityToPlaces < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :population, :integer
    add_column :places, :population_density, :integer
  end
end
