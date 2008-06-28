class AddAlbumsSortingFields < ActiveRecord::Migration
  def self.up
    add_column :albums, :sorting_artist, :string
    add_column :albums, :sorting_title,  :string
    
    for album in Album.find(:all, :order => "id ASC")
      raise "Unrecoverable save error" unless album.save
    end
  end

  def self.down
    remove_column :albums, :sorting_artist
    remove_column :albums, :sorting_title
  end
end
