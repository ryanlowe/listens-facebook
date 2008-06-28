require File.dirname(__FILE__) + '/../test_helper'

class RateControllerTest < ActionController::TestCase
  fixtures :albums

  def test_routing
    assert_routing '/rate/my/album/7-kasabian',        :controller => 'rate', :action => 'album',   :id => '7-kasabian'
    assert_routing '/update/album/7-kasabian/rating',  :controller => 'rate', :action => 'update',  :id => '7-kasabian'
  end
  
  #
  # album
  #
  
  def test_album
    login_user('12345678')
    add_app
    get :album, :id => albums(:kasabian)
    
    assert_response :success
    assert_template 'album'
    
    assert_equal albums(:kasabian), assigns(:album)
  end
  
  def test_album_not_creator
    login_user('55556666')
    add_app
    get :album, :id => albums(:kasabian)
    
    assert_response :success
    assert_template 'site/_error_404'
  end
  
  #
  # update
  #
  
  def test_update_no_review
    login_user('12345678')
    add_app
    assert_equal "", albums(:interpol).rating_to_s
    assert_equal nil, albums(:interpol).review
    album_count = Album.count
    
    post :update, :id => albums(:interpol), :album => { :rating_numerator => "8", :rating_denominator => "10" }
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    assert_equal album_count, Album.count
    albums(:interpol).reload
    assert_equal "8/10", albums(:interpol).rating_to_s
    assert_equal nil, albums(:interpol).review
  end
  
  def test_update_with_new_review
    login_user('12345678')
    add_app
    assert_equal "", albums(:interpol).rating_to_s
    assert_equal nil, albums(:interpol).review
    album_count = Album.count
    RateController.any_instance.stubs(:feed_publish).returns(true)
    
    post :update, :id => albums(:interpol), :album => { :rating_numerator => "9.2", :rating_denominator => "10" }, :review => "My favourite album of the year."
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    assert_equal album_count, Album.count
    albums(:interpol).reload
    assert_equal "9.2/10", albums(:interpol).rating_to_s
    assert_equal "My favourite album of the year.", albums(:interpol).review.body
  end
  
  def test_update_with_changed_review
    login_user('12345678')
    add_app
    assert_equal "7/10", albums(:kasabian).rating_to_s
    assert_equal "I love this album!", albums(:kasabian).review.body
    album_count = Album.count
    
    post :update, :id => albums(:kasabian), :album => { :rating_numerator => "8", :rating_denominator => "10" }, :review => "I like it!"
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    assert_equal album_count, Album.count
    albums(:kasabian).reload
    assert_equal "8/10", albums(:kasabian).rating_to_s
    assert_equal "I like it!", albums(:kasabian).review.body
  end
  
  def test_update_clear_review
    login_user('12345678')
    add_app
    assert_equal "7/10", albums(:kasabian).rating_to_s
    assert_equal "I love this album!", albums(:kasabian).review.body
    album_count = Album.count
    
    post :update, :id => albums(:kasabian), :album => { :rating_numerator => "8", :rating_denominator => "10" }, :review => ""
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    assert_equal album_count, Album.count
    albums(:kasabian).reload
    assert_equal "8/10", albums(:kasabian).rating_to_s
    assert_equal nil, albums(:kasabian).review
  end
  
  def test_update_not_creator
    login_user('55556666')
    add_app
    assert_equal "7/10", albums(:kasabian).rating_to_s
    album_count = Album.count
    
    post :update, :id => albums(:kasabian), :album => { :rating_numerator => "8", :rating_denominator => "10" }
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    assert_equal album_count, Album.count
    albums(:kasabian).reload
    assert_equal "Kasabian", albums(:kasabian).artist
    assert_equal "7/10", albums(:kasabian).rating_to_s
  end
  
  def test_update_error
    login_user('12345678')
    add_app
    assert_equal "7/10", albums(:kasabian).rating_to_s
    album_count = Album.count
    
    post :update, :id => albums(:kasabian), :album => { :rating_numerator => "8", :rating_denominator => "0" }
    
    #assert_response :success
    #assert_template 'new'
    
    assert_equal album_count, Album.count
    albums(:kasabian).reload
    assert_equal "Kasabian", albums(:kasabian).artist
    assert_equal "7/10", albums(:kasabian).rating_to_s
  end
  
  def test_update_get
    login_user('12345678')
    add_app
    assert_equal "7/10", albums(:kasabian).rating_to_s
    album_count = Album.count
    
    get :update, :id => albums(:kasabian), :album => { :rating_numerator => "8", :rating_denominator => "10" }
    
    #assert_response :redirect
    #assert_redirected_to :action => 'list'
    
    assert_equal album_count, Album.count
    albums(:kasabian).reload
    assert_equal "Kasabian", albums(:kasabian).artist
    assert_equal "7/10", albums(:kasabian).rating_to_s
  end
  
end
