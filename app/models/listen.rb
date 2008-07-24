class Listen < MonitoredRecord
  set_table_name "listens"
  
  belongs_to :album
  
  validates_presence_of :created_by
  validates_existence_of :album
  validates_presence_of :listened_at
  
  attr_accessible :listened_at

  def before_validation
    self[:listened_at] = Time.now.utc if self[:listened_at].nil?
  end
  
  def validate
    if album
      errors.add(:created_by, "must be the same as the album creator") unless (self[:created_by] == album.created_by)
    end
  end
  
  def destroy
    self.deleted_at = Time.now.utc
    raise "Unrecoverable error" unless save
  end
  
  ###
  
  def created_by?(uid)
    (self[:created_by].to_s == uid.to_s)
  end
  
  # self
  
  def self.find_all_by(uid, custom_options={})
    options = { :conditions => ["listens.created_by = ? AND listens.deleted_at IS NULL", uid], :order => "listens.listened_at DESC" }
    options.merge!(custom_options)
    Listen.find(:all, options)
  end
  
  def self.find_all_by_many(uids, custom_options={})
    options = { :conditions => ["listens.created_by IN (?) AND listens.deleted_at IS NULL", uids], :order => "listens.listened_at DESC" }
    options.merge!(custom_options)
    Listen.find(:all, options)
  end

end
