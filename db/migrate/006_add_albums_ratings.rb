class AddAlbumsRatings < ActiveRecord::Migration
  def self.up
    add_column :albums, :rating_numerator,   :float, :default => nil
    add_column :albums, :rating_denominator, :float, :default => nil
    add_column :albums, :rating,             :float, :default => nil
  end

  def self.down
    remove_column :albums, :rating_numerator
    remove_column :albums, :rating_denominator
    remove_column :albums, :rating
  end
end
