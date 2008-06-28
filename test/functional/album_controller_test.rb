require File.dirname(__FILE__) + '/../test_helper'

class AlbumControllerTest < ActionController::TestCase
  tests AlbumController
  fixtures :albums

  def test_routing
    assert_routing '/my/albums',           :controller => 'album', :action => 'list'
    assert_routing '/my/album/7-kasabian', :controller => 'album', :action => 'show', :id => '7-kasabian' 
    assert_routing '/add/album',           :controller => 'album', :action => 'new'
    assert_routing '/create/album',        :controller => 'album', :action => 'create'
    assert_routing '/edit/album/7-kasabian',    :controller => 'album', :action => 'edit',    :id => '7-kasabian'
    assert_routing '/update/album/7-kasabian',  :controller => 'album', :action => 'update',  :id => '7-kasabian'
    assert_routing '/delete/album/7-kasabian',  :controller => 'album', :action => 'delete',  :id => '7-kasabian'
    assert_routing '/destroy/album/7-kasabian', :controller => 'album', :action => 'destroy', :id => '7-kasabian'
  end
  
  #
  # list
  #
  
  def test_list
    login_user('12345678')
    add_app
    get :list
    
    assert_response :success
    assert_template 'list'
    
    assert_equal Album.count, assigns(:albums).size
  end
  
  #
  # show
  #
  
  def test_show
    login_user('12345678')
    add_app
    get :show, :id => albums(:kasabian)
    
    assert_response :success
    assert_template 'show'
    
    assert_equal albums(:kasabian), assigns(:album)
  end
  
  def test_show_not_creator
    login_user('55556666')
    add_app
    get :show, :id => albums(:kasabian)
    
    assert_response :success
    assert_template 'site/_error_404'
  end
  
  #
  # new
  #
  
  def test_new
    login_user('12345678')
    add_app
    get :new
    
    #assert_response :success
    #assert_template 'new'
  end
  
  #
  # create
  #
  
  def test_create
    login_user('12345678')
    add_app
    album_count = Album.count
    post :create, :album => { :artist => "Radiohead", :title => "In Rainbows", :year => "2007" }
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    assert_equal album_count+1, Album.count
    album = Album.find(:first, :order => "id DESC")
    assert_equal 12345678, album.created_by
  end
  
  def test_create_error
    login_user('12345678')
    add_app
    album_count = Album.count
    post :create, :album => { :title => "In Rainbows", :year => "2007" }
    
    #assert_response :success
    #assert_template 'new'
    
    assert_equal album_count, Album.count
  end
  
  def test_create_get
    login_user('12345678')
    add_app
    album_count = Album.count
    get :create, :album => { :artist => "Radiohead", :title => "In Rainbows", :year => "2007" }
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    assert_equal album_count, Album.count
  end
  
  #
  # edit
  #
  
  def test_edit
    login_user('12345678')
    add_app
    get :edit, :id => albums(:kasabian)
    
    assert_response :success
    assert_template 'edit'
    
    assert_equal albums(:kasabian), assigns(:album)
  end
  
  def test_edit_not_creator
    login_user('55556666')
    add_app
    get :edit, :id => albums(:kasabian)
    
    assert_response :success
    assert_template 'site/_error_404'
  end
  
  #
  # update
  #
  
  def test_update
    login_user('12345678')
    add_app
    album_count = Album.count
    
    post :update, :id => albums(:kasabian), :album => { :artist => "Radiohead" }
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    assert_equal album_count, Album.count
    albums(:kasabian).reload
    assert_equal "Radiohead", albums(:kasabian).artist 
  end
  
  def test_update_not_creator
    login_user('55556666')
    add_app
    album_count = Album.count
    
    post :update, :id => albums(:kasabian), :album => { :artist => "Radiohead" }
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    assert_equal album_count, Album.count
    albums(:kasabian).reload
    assert_equal "Kasabian", albums(:kasabian).artist 
  end
  
  def test_update_error
    login_user('12345678')
    add_app
    album_count = Album.count
    
    post :update, :id => albums(:kasabian), :album => { :artist => "" }
    
    #assert_response :success
    #assert_template 'new'
    
    assert_equal album_count, Album.count
    albums(:kasabian).reload
    assert_equal "Kasabian", albums(:kasabian).artist
  end
  
  def test_update_get
    login_user('12345678')
    add_app
    album_count = Album.count
    
    get :update, :id => albums(:kasabian), :album => { :artist => "Radiohead" }
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    assert_equal album_count, Album.count
    albums(:kasabian).reload
    assert_equal "Kasabian", albums(:kasabian).artist
  end
  
  #
  # delete
  #
  
  def test_delete
    login_user('12345678')
    add_app
    get :delete, :id => albums(:kasabian)
    
    assert_response :success
    assert_template 'delete'
    
    assert_equal albums(:kasabian), assigns(:album)
  end
  
  def test_delete_not_creator
    login_user('55556666')
    add_app
    get :delete, :id => albums(:kasabian)
    
    assert_response :success
    assert_template 'site/_error_404'
  end
  
  #
  # destroy
  #
  
  def test_destroy
    login_user('12345678')
    add_app
    album_count = Album.count
    my_count = Album.find_all_by('12345678').size
    assert_equal album_count, my_count
    
    post :destroy, :id => albums(:kasabian)
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    albums(:kasabian).reload
    assert_not_nil albums(:kasabian).deleted_at
    
    assert_equal album_count, Album.count
    assert_equal my_count-1, Album.find_all_by('12345678').size
  end
  
  def test_destroy_not_creator
    login_user('55556666')
    add_app
    album_count = Album.count
    my_count = Album.find_all_by('12345678').size
    assert_equal album_count, my_count
    
    post :destroy, :id => albums(:kasabian)
    
    assert_response :success
    assert_template 'site/_error_404'
    
    assert_equal album_count, Album.count
    assert_equal my_count, Album.find_all_by('12345678').size
  end
  
  def test_destroy_get
    login_user('12345678')
    add_app
    album_count = Album.count
    my_count = Album.find_all_by('12345678').size
    assert_equal album_count, my_count
    
    get :destroy, :id => albums(:kasabian)
    
    assert_response :redirect
    assert_redirected_to :action => 'list'
    
    albums(:kasabian).reload
    assert_nil albums(:kasabian).deleted_at
    
    assert_equal album_count, Album.count
    assert_equal my_count, Album.find_all_by('12345678').size
  end
end
