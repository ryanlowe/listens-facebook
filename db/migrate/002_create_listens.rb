class CreateListens < ActiveRecord::Migration
  def self.up
    create_table :listens do |t|
      t.column :created_by,  :integer
      t.column :created_at,  :datetime
      t.column :updated_at,  :datetime
      t.column :deleted_at,  :datetime, :default => nil
      t.column :album_id,    :integer
      t.column :listened_at, :datetime
    end
  end

  def self.down
    drop_table :listens
  end
end
