module PublicHelper

  def url_for_public_album(album)
    url_for :controller => 'public', :action => 'album', :id => album
  end
  
  def link_public_album(album)
    link_to album.to_s, url_for_public_album(album)
  end
  
end
