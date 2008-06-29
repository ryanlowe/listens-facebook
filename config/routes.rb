ActionController::Routing::Routes.draw do |map|

  map.with_options :controller => 'site' do |site|
    site.faq  '/faq',  :action => 'faq'
    site.boom '/boom', :action => 'boom'
  end
  
  map.with_options :controller => 'public' do |public_c|
    public_c.connect '/by/:uid',          :action => 'listens'
    public_c.connect '/albums/:uid',      :action => 'albums'
    public_c.connect '/album/:id',        :action => 'album'
    public_c.connect '/comments/:uid',    :action => 'comments'
    public_c.connect '/recommendations/:uid',  :action => 'recommends'
  end
  
  map.with_options :controller => 'rate' do |rate|
    rate.connect '/rate/my/album/:id',        :action => 'album'
    rate.connect '/update/album/:id/rating',  :action => 'update'
  end
  
  map.with_options :controller => 'listen' do |listen|
    listen.front   '/', :action => 'list'
    listen.connect '/add/past/listen/for/:album_id', :action => 'new'
    listen.connect '/create/listen/for/:album_id', :action => 'create'
    listen.connect '/delete/listen/:id',  :action => 'delete'
    listen.connect '/destroy/listen/:id', :action => 'destroy'
  end
  
  map.with_options :controller => 'comment' do |comment|
    comment.comments '/my/comments', :action => 'list'
    comment.connect  '/comment/on/:album_id', :action => 'new'
    comment.connect  '/create/comment/on/:album_id', :action => 'create'
    comment.connect  '/delete/comment/:id',  :action => 'delete'
    comment.connect  '/destroy/comment/:id', :action => 'destroy'
  end
  
  map.with_options :controller => 'album' do |album|
    album.albums  '/my/albums',    :action => 'list'
    album.connect '/my/album/:id', :action => 'show'
    album.add     '/add/album', :action => 'new'
    album.connect '/create/album', :action => 'create'
    album.connect '/edit/album/:id',    :action => 'edit'
    album.connect '/update/album/:id',  :action => 'update'
    album.connect '/delete/album/:id',  :action => 'delete'
    album.connect '/destroy/album/:id', :action => 'destroy'
  end
  
  map.connect '/dummy_facebook/:action/:id', :controller => 'dummy_facebook'
end
