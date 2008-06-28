require File.dirname(__FILE__) + '/../test_helper'

class ListenControllerTest < ActionController::TestCase
  tests ListenController
  fixtures :albums, :listens

  def test_routing
    assert_routing '/', :controller => 'listen', :action => 'list'
    assert_routing '/add/past/listen/for/7-kasabian', :controller => 'listen', :action => 'new', :album_id => '7-kasabian'
    assert_routing '/create/listen/for/7-kasabian', :controller => 'listen', :action => 'create', :album_id => '7-kasabian'
    assert_routing '/delete/listen/7-kasabian', :controller => 'listen', :action => 'delete', :id => '7-kasabian'
    assert_routing '/destroy/listen/7-kasabian', :controller => 'listen', :action => 'destroy', :id => '7-kasabian'
  end
  
  #
  # list
  #
  
  def test_list_logged_in_no_friend_listens
    login_user('12345678')
    add_app
    get :list
    
    assert_response :success
    assert_template 'list'
    
    assert_equal 2, assigns(:listens).size
    assert_equal 0, assigns(:friend_listens).size
  end
  
  def test_list_logged_in_with_friend_listens
    login_user('55556666')
    add_app
    ListenController.any_instance.stubs(:friends).returns([12345678])
    get :list
    
    assert_response :success
    assert_template 'list'
    
    assert_equal 0, assigns(:listens).size
    assert_equal 2, assigns(:friend_listens).size
  end
  
  #
  # new
  #
  
  def test_new
    login_user('12345678')
    add_app
    ListenController.any_instance.stubs(:update_profile).returns(true)
    
    get :new, :album_id => albums(:kasabian)
    
    assert_response :success
    assert_template 'new'
  end
  
  def test_new_not_album_creator
    login_user('55556666')
    add_app
    ListenController.any_instance.stubs(:update_profile).returns(true)
    
    get :new, :album_id => albums(:kasabian)
    
    assert_response :success
    assert_template 'site/_error_404'
  end
  
  #
  # create
  #
  
  def test_create
    login_user('12345678')
    add_app
    listen_count = Listen.count
    ListenController.any_instance.stubs(:update_profile).returns(true)
    ListenController.any_instance.stubs(:feed_publish).returns(true)
    
    post :create, :album_id => albums(:interpol).id
    
    #assert_response :redirect
    #assert_redirected_to :controller => 'album', :action => 'show', :id => albums(:interpol)
    
    assert_equal listen_count+1, Listen.count
    listen = Listen.find(:first, :order => "id DESC")
    assert_equal 12345678, listen.created_by
  end
  
  def test_create_past_time
    login_user('12345678')
    add_app
    listen_count = Listen.count
    ListenController.any_instance.stubs(:update_profile).returns(true)
    ListenController.any_instance.stubs(:feed_publish).returns(true)
    
    post :create, :album_id => albums(:interpol).id, :listen => { :listened_at => "2007-12-06 13:14" }
    
    #assert_response :redirect
    #assert_redirected_to :controller => 'album', :action => 'show', :id => albums(:interpol)
    
    assert_equal listen_count+1, Listen.count
    listen = Listen.find(:first, :order => "id DESC")
    assert_equal 12345678, listen.created_by
  end
  
  def test_create_not_album_creator
    login_user('55556666')
    add_app
    listen_count = Listen.count
    ListenController.any_instance.stubs(:update_profile).returns(true)
    ListenController.any_instance.stubs(:feed_publish).returns(true)
    
    post :create, :album_id => albums(:interpol).id
    
    assert_response :success
    assert_template 'site/_error_404'
    
    assert_equal listen_count, Listen.count
  end
  
  def test_create_no_album_id
    listen_count = Listen.count
    
    assert_raises(ActionController::RoutingError) {
      post :create
    }
    
    assert_equal listen_count, Listen.count
  end
  
  def test_create_get
    login_user('12345678')
    add_app
    listen_count = Listen.count
    
    get :create, :album_id => albums(:interpol).id
    
    #assert_response :redirect
    #assert_redirected_to :controller => 'album', :action => 'list'
    
    assert_equal listen_count, Listen.count
  end
  
  #
  # delete
  #
  
  def test_delete
    login_user('12345678')
    add_app
    
    get :delete, :id => listens(:interpol_past)
    
    assert_response :success
    assert_template 'delete'
    
    assert_equal listens(:interpol_past), assigns(:listen)
  end
  
  def test_delete_not_creator
    login_user('55556666')
    add_app
    
    get :delete, :id => listens(:interpol_past)
    
    assert_response :success
    assert_template 'site/_error_404'
  end
  
  #
  # destroy
  #
  
  def test_destroy
    login_user('12345678')
    add_app
    listen_count = Listen.count
    my_count = albums(:interpol).listens.size
    assert_equal listen_count, my_count
    ListenController.any_instance.stubs(:update_profile).returns(true)
    
    post :destroy, :id => listens(:interpol_past)
    
    #assert_response :redirect
    #assert_redirected_to :controller => 'album', :action => 'show', :id => albums(:interpol)
    
    listens(:interpol_past).reload
    assert_not_nil listens(:interpol_past).deleted_at
    
    assert_equal listen_count, Listen.count
    assert_equal my_count-1, albums(:interpol).listens.size
  end
  
  def test_destroy_not_creator
    login_user('55556666')
    add_app
    listen_count = Listen.count
    my_count = albums(:interpol).listens.size
    assert_equal listen_count, my_count
    ListenController.any_instance.stubs(:update_profile).returns(true)
    
    post :destroy, :id => listens(:interpol_past)
    
    assert_response :success
    assert_template 'site/_error_404'
    
    assert_equal listen_count, Listen.count
    assert_equal my_count, albums(:interpol).listens.size
  end
  
  def test_destroy_get
    login_user('12345678')
    add_app
    listen_count = Listen.count
    my_count = albums(:interpol).listens.size
    assert_equal listen_count, my_count
    
    get :destroy, :id => listens(:interpol_past)
    
    #assert_response :redirect
    #assert_redirected_to :controller => 'album', :action => 'list'
    
    listens(:interpol_past).reload
    assert_nil listens(:interpol_past).deleted_at
    
    assert_equal listen_count, Listen.count
    assert_equal my_count, albums(:interpol).listens.size
  end
end
