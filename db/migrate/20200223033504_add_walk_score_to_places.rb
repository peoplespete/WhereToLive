class AddWalkScoreToPlaces < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :walk_score, :integer
  end
end
