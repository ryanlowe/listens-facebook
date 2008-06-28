ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  map.with_options :controller => 'site' do |site|
    site.faq   '/faq',  :action => 'faq'
    site.blow  '/blow', :action => 'blow'
  end
  
  map.with_options :controller => 'public' do |public|
    public.connect '/by/:uid',          :action => 'listens'
    public.connect '/albums/:uid',      :action => 'albums'
    public.connect '/album/:id',        :action => 'album'
    public.connect '/comments/:uid',    :action => 'comments'
    public.connect '/recommendations/:uid',  :action => 'recommends'
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
  


  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
  
  map.connect '/dummy_facebook/:action/:id', :controller => 'dummy_facebook'
end
