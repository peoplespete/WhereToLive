class AddsHomePriceToPlaces < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :home_price, :integer
  end
end
