class AddsCountyAndPostcodeToPlaces < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :county, :string
    add_column :places, :postcode, :string
  end
end
