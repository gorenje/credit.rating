class AddDeatilsToBonitaetHistory < ActiveRecord::Migration[4.2]
  def change
    add_column :rating_histories, :details, :hstore
    add_column :ratings, :details, :hstore
  end
end
