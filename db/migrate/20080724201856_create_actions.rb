class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :type
      t.integer  :done_by
      t.datetime :done_at
      t.string   :monitorable_type
      t.integer  :monitorable_id
      t.boolean  :feed_queued, :default => false
      t.datetime :feed_published_at
    end
  end

  def self.down
    drop_table :actions
  end
end
