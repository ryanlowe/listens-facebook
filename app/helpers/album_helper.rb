module AlbumHelper

  def url_for_album(album)
    url_for :controller => 'album', :action => 'show', :id => album
  end
  def link_album(album)
    link_to album.to_s, :controller => 'album', :action => 'show', :id => album
  end
end
