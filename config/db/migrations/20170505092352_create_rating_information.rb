class CreateRatingInformation < ActiveRecord::Migration[4.2]
  def change
    create_table :ratings do |t|
      t.integer :score

      t.belongs_to :user
      t.timestamps :null => false
    end

    create_table :rating_histories do |t|
      t.integer :score

      t.belongs_to :user
      t.timestamps :null => false
    end
  end
end
