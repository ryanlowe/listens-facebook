class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.column :created_by, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime, :default => nil
      t.column :artist,     :string
      t.column :title,      :string
      t.column :year,       :string
    end

    execute "alter table albums modify created_by bigint"
  end

  def self.down
    drop_table :albums
  end
end
