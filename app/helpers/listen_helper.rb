module ListenHelper

  def listen_count(album)
    count = album.total_listens 
    return "" if count < 1
    "x"+count.to_s
  end
  
end
