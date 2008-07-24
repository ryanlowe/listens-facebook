class Action < ActiveRecord::Base
  belongs_to :monitorable, :polymorphic => true
  
  validates_presence_of :done_by
  validates_presence_of :done_at
  #validates_presence_of :type
  validates_presence_of :monitorable_type
  validates_presence_of :monitorable_id
  
  def before_validation
    self[:done_by] = monitorable.created_by if self[:done_by].nil? and !self.monitorable.nil?
    self[:done_at] = Time.now.utc if self[:done_at].nil?
    self[:feed_queued] = true unless self[:monitorable_type] == "Album"
  end
  
end
