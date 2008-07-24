class Review < MonitoredRecord
  set_table_name "reviews"

  belongs_to :album
  
  validates_presence_of :created_by
  validates_existence_of :album
  validates_length_of :body, :within => 1..1024
  
  attr_accessible :body

  def before_validation
    self[:body].strip! unless self[:body].nil?
  end
  
  def validate
    if self.album
      errors.add(:created_by, "must be the same as the album") unless self.album.created_by == self.created_by
      errors.add(:album_id, "already has a review") if self.new_record? and Album.find(self.album_id).review
    end
  end
  
  def destroy
    self.deleted_at = Time.now.utc
    raise "Unrecoverable error" unless self.save
  end

  # self
  
  def self.set_for(album, text)
    update_feed = false
    r = album.review
    if r.nil?
      return false if (text.nil? or text.length < 1)
      r = Review.new
      r.created_by = album.created_by
      r.album_id   = album.id
      update_feed = true
    else
      if (text.nil? or text.length < 1)
        r.destroy
        return false 
      end
    end
    r.body = text
    raise "Unrecoverable error" unless r.save
    update_feed
  end
end
