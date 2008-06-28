class AddAlbumsRecommendedAndPlayCount < ActiveRecord::Migration
  def self.up
    add_column :albums, :previous_listen_count, :integer
    add_column :albums, :recommended_by,        :integer
    
    execute "alter table albums modify recommended_by bigint"
  end

  def self.down
    remove_column :albums, :previous_listen_count
    remove_column :albums, :recommended_by
  end
end
