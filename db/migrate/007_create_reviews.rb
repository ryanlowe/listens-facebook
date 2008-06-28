class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.column :created_by,  :integer
      t.column :created_at,  :datetime
      t.column :updated_at,  :datetime
      t.column :deleted_at,  :datetime, :default => nil
      t.column :album_id,    :integer
      t.column :body,        :text
    end
  end

  def self.down
    drop_table :reviews
  end
end
