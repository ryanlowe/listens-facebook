require File.dirname(__FILE__) + '/../test_helper'

class PublicControllerTest < ActionController::TestCase
  tests PublicController
  fixtures :albums, :listens, :comments

  # Replace this with your real tests.
  def test_routing
    assert_routing '/by/12345678',      :controller => 'public', :action => 'listens', :uid => '12345678'
    assert_routing '/albums/12345678',  :controller => 'public', :action => 'albums',  :uid => '12345678'
    assert_routing '/album/7-kasabian', :controller => 'public', :action => 'album',   :id  => '7-kasabian'
    assert_routing '/album',            :controller => 'public', :action => 'album'
    assert_routing '/comments/12345678',   :controller => 'public', :action => 'comments',   :uid => '12345678'
    assert_routing '/recommendations/12345678', :controller => 'public', :action => 'recommends', :uid => '12345678'
  end
  
  #
  # listens
  #
  
  def test_listens_no_uid
    assert_raises(ActionController::RoutingError) {
      get :listens
    }
  end

  def test_listens_creator
    get :listens, :uid => '12345678' 
    
    assert_response :success
    assert_template 'listens'
    
    assert_equal 2, assigns(:listens).size
    assert_equal 1, assigns(:rotation).size
    assert_equal "2", assigns(:rotation)[0].rotation_count # same album played twice
  end
  
# NOTE: Let Facebook do access control using <fb:if-is-friends-with-viewer/>
#
#  def test_listens_creator
#    is_user('12345678')
#    
#    get :listens, :uid => '12345678' 
#    
#    assert_response :success
#    #assert_template...
#    
#    assert_equal 2, assigns(:listens).size
#    assert_equal 1, assigns(:rotation).size
#    assert_equal "2", assigns(:rotation)[0].rotation_count # same album played twice
#  end
#  
#  def test_listens_friend
#    is_user('55556666')
#    PublicController.any_instance.stubs(:friend_of_user?).returns(true)
#    
#    get :listens, :uid => '12345678' 
#    
#    assert_response :success
#    #assert_template...
#    
#    assert_equal 2, assigns(:listens).size
#    assert_equal 1, assigns(:rotation).size
#    assert_equal "2", assigns(:rotation)[0].rotation_count # same album played twice
#  end
#  
#  def test_listens_stranger
#    is_user('55556666')
#    PublicController.any_instance.stubs(:friend_of_user?).returns(false)
#    
#    get :listens, :uid => '12345678' 
#    
#    assert_response :success
#    assert_template 'site/_error_404'
#  end
  
  #
  # albums
  #
  
  def test_albums_no_uid
    assert_raises(ActionController::RoutingError) {
      get :albums
    }
  end
  
  def test_albums
    get :albums, :uid => '12345678' 
    
    assert_response :success
    assert_template 'albums'
    
    assert_equal 2, assigns(:albums).size
  end
  
# NOTE: Let Facebook do access control using <fb:if-is-friends-with-viewer/>
#
#  def test_albums_creator
#    is_user('12345678')
#    
#    get :albums, :uid => '12345678' 
#    
#    assert_response :success
#    #assert_template...
#    
#    assert_equal 2, assigns(:albums).size
#  end
#  
#  def test_albums_friend
#    is_user('55556666')
#    PublicController.any_instance.stubs(:friend_of_user?).returns(true)
#    
#    get :albums, :uid => '12345678' 
#    
#    assert_response :success
#    #assert_template...
#    
#    assert_equal 2, assigns(:albums).size
#  end
#  
#  def test_albums_stranger
#    is_user('55556666')
#    PublicController.any_instance.stubs(:friend_of_user?).returns(false)
#    
#    get :albums, :uid => '12345678' 
#    
#    assert_response :success
#    assert_template 'site/_error_404'
#  end
  
  #
  # album
  #
  
  def test_album_no_id
    is_user('12345678')
    
    assert_raises(ActiveRecord::RecordNotFound) {
      get :album
    }
  end
  
  def test_album
    get :album, :id => albums(:interpol) 
    
    assert_response :success
    assert_template 'album'
    
    assert_equal albums(:interpol), assigns(:album)
  end

# NOTE: Let Facebook do access control using <fb:if-is-friends-with-viewer/>
#
#  def test_album_creator
#    is_user('12345678')
#    assert albums(:interpol).created_by?('12345678')
#    
#    get :album, :id => albums(:interpol) 
#    
#    assert_response :success
#    #assert_template...
#    
#    assert_equal albums(:interpol), assigns(:album)
#  end
#  
#  def test_album_friend
#    is_user('55556666')
#    assert !albums(:interpol).created_by?('55556666')
#    PublicController.any_instance.stubs(:friend_of_user?).returns(true)
#    
#    get :album, :id => albums(:interpol) 
#    
#    assert_response :success
#    #assert_template...
#    
#    assert_equal albums(:interpol), assigns(:album)
#  end
#  
#  def test_album_stranger
#    is_user('55556666')
#    assert !albums(:interpol).created_by?('55556666')
#    PublicController.any_instance.stubs(:friend_of_user?).returns(false)
#    
#    get :album, :id => albums(:interpol) 
#    
#    assert_response :success
#    assert_template 'site/_error_404'
#  end
  
  #
  # comments
  #
  
  def test_comments_no_uid
    assert_raises(ActionController::RoutingError) {
      get :comments
    }
  end
  
  def test_comments
    get :comments, :uid => '12345678' 
    
    assert_response :success
    assert_template 'comments'
    
    assert_equal 1, assigns(:sent).size
  end

# NOTE: Let Facebook do access control using <fb:if-is-friends-with-viewer/>
#
#  def test_comments_creator
#    is_user('12345678')
#    
#    get :comments, :uid => '12345678' 
#    
#    assert_response :success
#    #assert_template...
#    
#    assert_equal 1, assigns(:sent).size
#  end
#  
#  def test_comments_friend
#    is_user('55556666')
#    PublicController.any_instance.stubs(:friend_of_user?).returns(true)
#    
#    get :comments, :uid => '12345678' 
#    
#    assert_response :success
#    #assert_template...
#    
#    assert_equal 1, assigns(:sent).size
#  end
#  
#  def test_comments_stranger
#    is_user('55556666')
#    PublicController.any_instance.stubs(:friend_of_user?).returns(false)
#    
#    get :comments, :uid => '12345678' 
#    
#    assert_response :success
#    assert_template 'site/_error_404'
#  end

  #
  # recommends
  #
  
  def test_recommends_no_uid
    assert_raises(ActionController::RoutingError) {
      get :recommends
    }
  end
  
  def test_recommends
    get :recommends, :uid => '12345678' 
    
    assert_response :success
    assert_template 'recommends'
    
    assert_equal 0, assigns(:given).size
    assert_equal 0, assigns(:received).size
  end

# NOTE: Let Facebook do access control using <fb:if-is-friends-with-viewer/>
#
#  def test_recommends_creator
#    is_user('12345678')
#    
#    get :recommends, :uid => '12345678' 
#    
#    assert_response :success
#    #assert_template...
#    
#    #assert_equal 1, assigns(:sent).size
#  end
#  
#  def test_recommends_friend
#    is_user('55556666')
#    PublicController.any_instance.stubs(:friend_of_user?).returns(true)
#    
#    get :recommends, :uid => '12345678' 
#    
#    assert_response :success
#    #assert_template...
#    
#    #assert_equal 1, assigns(:sent).size
#  end
#  
#  def test_recommends_stranger
#    is_user('55556666')
#    PublicController.any_instance.stubs(:friend_of_user?).returns(false)
#    
#    get :recommends, :uid => '12345678' 
#    
#    assert_response :success
#    assert_template 'site/_error_404'
#  end
  
end
