class Album < MonitoredRecord
  set_table_name "albums"

  has_many :listens,  :conditions => "deleted_at IS NULL", :order => "listened_at DESC"
  has_many :comments, :conditions => "deleted_at IS NULL", :order => "created_at ASC"
  has_one  :review,   :conditions => "deleted_at IS NULL"
  
  validates_presence_of :created_by
  validates_presence_of :artist
  validates_presence_of :title
  validates_presence_of :sorting_artist
  validates_presence_of :sorting_title
  validates_length_of :artist, :maximum => 200
  validates_length_of :title, :maximum => 200
  validates_length_of :sorting_artist, :maximum => 200
  validates_length_of :sorting_title, :maximum => 200
  validates_length_of :year, :maximum => 4, :allow_nil => true
  validates_numericality_of :rating_numerator, :allow_nil => true
  validates_numericality_of :rating_denominator, :allow_nil => true
  validates_numericality_of :rating, :allow_nil => true
  
  attr_accessible :artist, :title, :year,
                  #004
                  :previous_listen_count, :recommended_by,
                  #006
                  :rating_numerator, :rating_denominator
  
  def before_validation
    self[:artist].strip! unless self[:artist].nil?
    self[:title].strip!  unless self[:title].nil?
    self[:year].strip!   unless self[:year].nil?
    self[:sorting_artist] = Album.sorting_string(self[:artist])
    self[:sorting_title]  = Album.sorting_string(self[:title])
    if rating_invalid?
      self[:rating] = nil
    else
      self[:rating] = self[:rating_numerator]/self[:rating_denominator]
    end
  end
  
  def validate
    if (self[:artist].to_s.length > 0) and (self[:title].to_s.length > 0)
      if self.new_record?
        dupe = Album.find_by_created_by_and_artist_and_title(self[:created_by], self[:artist], self[:title])
        errors.add(:title, "has already been added for that artist") unless dupe.nil?
      end
    end
  end
  
  def destroy
    self.deleted_at = Time.now.utc
    raise "Unrecoverable error" unless save
  end
  
  def rating_numerator_to_s
    text = self[:rating_numerator].to_s
    text = text[0,text.length-2] if text =~ /.0$/
    text
  end
  
  def rating_denominator_to_s
    text = self[:rating_denominator].to_s
    text = text[0,text.length-2] if text =~ /.0$/
    text
  end
  
  def rating_invalid?
    self[:rating_numerator].nil? or self[:rating_denominator].nil?
  end
  
  def rated?
    !rating_invalid? or !self.review.nil? 
  end
  
  def rating_to_s
    return "" if rating_invalid?
    rating_numerator_to_s+"/"+rating_denominator_to_s
  end
  
  def rating_to_s_long
    return "Not rated" if rating_invalid?
    rating_to_s
  end
  
  ###
  
  def all_by_same_artist(custom_options={})
    options = Hash.new
    options[:conditions] = ["albums.created_by = ? AND albums.artist = ?", self[:created_by], self[:artist]]
    options[:order] = "albums.year, albums.sorting_title"
    options.merge!(custom_options)
    Album.find(:all, options)
  end
  
  def created_by?(uid)
    (self[:created_by].to_s == uid.to_s)
  end
  
  def destroyable?
    listens.size == 0
  end
  
  def total_listens
    return listens.size unless previous_listen_count
    listens.size+previous_listen_count
  end
  
  def to_s
    text  = self.artist.to_s.strip+": "+self.title.to_s.strip
    text += " ("+self.year.to_s.strip+")" if self.year.to_s.strip.length > 0
    text
  end
  
  def to_params
    self.id
  end
  
  # self
  
  def self.sorting_string(text)
    sorting = text.to_s
    return sorting[4,sorting.length-4] if (text.to_s.downcase =~ /^the /)
    sorting
  end
  
  def self.find_all_by(uid)
    Album.find(:all, :conditions => ["albums.created_by = ? AND albums.deleted_at IS NULL", uid],
                 :order => "albums.sorting_artist, albums.year, albums.sorting_title")
  end
  
  def self.find_all_rated_by(uid)
    Album.find(:all, :conditions => ["albums.rating IS NOT NULL AND albums.created_by = ? AND albums.deleted_at IS NULL", uid],
                 :order => "albums.rating DESC, albums.sorting_artist, albums.year, albums.sorting_title")
  end
  
  def self.find_all_in_rotation_by(uid, custom_options={})
    days = custom_options[:days].nil? ? 30 : custom_options[:days]
    custom_options.delete :days
    
    options = Hash.new
    options[:select] = "albums.*, COUNT(album_id) AS rotation_count"
    options[:joins] = "INNER JOIN listens ON listens.album_id=albums.id"
    options[:conditions] = ["TO_DAYS(NOW())-TO_DAYS(listens.listened_at) <= ? AND albums.created_by = ? AND listens.deleted_at IS NULL AND albums.deleted_at IS NULL", days, uid]
    options[:group] = "album_id"
    options[:order] = "rotation_count DESC, albums.sorting_artist, albums.sorting_title"
    options.merge!(custom_options)
    results = Album.find(:all, options)
    results.delete_if { |a| a.rotation_count.to_i < 2 }
  end
  
  def self.find_all_recommended_by(uid, custom_options={})
    options = Hash.new
    options[:conditions] = ["albums.recommended_by = ? AND albums.deleted_at IS NULL", uid]
    options[:order] = "created_by ASC, albums.sorting_artist, albums.sorting_title"
    options.merge!(custom_options)
    results = Album.find(:all, options)
  end

  def self.find_all_recommended_to(uid, custom_options={})
    options = Hash.new
    options[:conditions] = ["albums.created_by = ? AND recommended_by IS NOT NULL AND albums.deleted_at IS NULL", uid]
    options[:order] = "recommended_by ASC, albums.sorting_artist, albums.sorting_title"
    options.merge!(custom_options)
    results = Album.find(:all, options)
  end
  
end
