require File.dirname(__FILE__) + '/../test_helper'

class SiteControllerTest < ActionController::TestCase
  tests SiteController
  fixtures :albums, :listens

  def test_routing
    assert_routing '/faq', :controller => 'site', :action => 'faq'
  end
  
  #
  # front
  #
  
#  def test_front_logged_in_no_friend_listens
#    login_user('12345678')
#    get :front
#    
#    assert_response :success
#    assert_template 'front'
#    
#    assert_equal 2, assigns(:listens).size
#    assert_equal 0, assigns(:friend_listens).size
#  end
#  
#  def test_front_logged_in_with_friend_listens
#    login_user('55556666')
#    SiteController.any_instance.stubs(:friends).returns([12345678])
#    get :front
#    
#    assert_response :success
#    assert_template 'front'
#    
#    assert_equal 0, assigns(:listens).size
#    assert_equal 2, assigns(:friend_listens).size
#  end
#  
#  def test_front
#    is_user('19192727')
#    get :front
#    
#    assert_response :success
#    assert_template 'front'
#    
#    assert_nil assigns(:listens)
#    assert_nil assigns(:friend_listens)
#  end
#  
#  def test_front_anon
#    get :front
#    
#    assert_response :success
#    assert_template 'front'
#    
#    assert_nil assigns(:listens)
#    assert_nil assigns(:friend_listens)
#  end
  
  #
  # faq
  #
  
  def test_faq
    is_user('12345678')
    get :faq
    
    assert_response :success
    assert_template 'faq'
  end
  
  def test_faq_anon
    get :faq
    
    assert_response :success
    assert_template 'faq'
  end
end
