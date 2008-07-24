class Comment < MonitoredRecord
  set_table_name "comments"

  belongs_to :album
  
  validates_presence_of :created_by
  validates_existence_of :album
  validates_length_of :body, :within => 1..1024
  
  attr_accessible :body
  
  def before_validation
    self[:body].strip! unless self[:body].nil?
  end
  
  def destroy
    self.deleted_at = Time.now.utc
    raise "Unrecoverable error" unless save
  end
  
  ###
  
  def created_by?(uid)
    (self[:created_by].to_s == uid.to_s)
  end
  
  def on_own_album?
    (self[:created_by].to_s == self.album[:created_by].to_s)
  end
  
  # self
  
  def self.find_all_by(uid, custom_options={})
    options = Hash.new
    options[:conditions] = ["comments.created_by = ? AND comments.deleted_at IS NULL", uid]
    options[:order] = "comments.created_at DESC"
    options.merge!(custom_options)
    Comment.find(:all, options)
  end
  
  def self.find_all_on_albums_by(uid, custom_options={})
    options = Hash.new
    options[:joins] = "INNER JOIN albums ON comments.album_id=albums.id"
    options[:conditions] = ["albums.created_by = ? AND comments.created_by <> ? AND comments.deleted_at IS NULL", uid, uid]
    options[:order] = "comments.created_at DESC"
    options.merge!(custom_options)
    Comment.find(:all, options)
  end
  
end
