require File.dirname(__FILE__) + '/../test_helper'

class CommentControllerTest < ActionController::TestCase
  tests CommentController
  fixtures :albums, :comments

  def test_routing
    assert_routing '/my/comments', :controller => 'comment', :action => 'list'
    assert_routing '/comment/on/7-kasabian', :controller => 'comment', :action => 'new', :album_id => '7-kasabian'
    assert_routing '/create/comment/on/7-kasabian', :controller => 'comment', :action => 'create', :album_id => '7-kasabian'
    assert_routing '/delete/comment/41', :controller => 'comment', :action => 'delete', :id => '41'
    assert_routing '/destroy/comment/41', :controller => 'comment', :action => 'destroy', :id => '41'
  end
  
  #
  # list
  #
  
  def test_list
    login_user('12345678')
    
    get :list
    
    #assert_response :success
    #assert_template 'list'
    
    assert_equal 1, assigns(:sent).size
    assert_equal 1, assigns(:received).size
  end
  
  #
  # new
  #
  
  def test_new_own_album
    login_user('12345678')
    assert albums(:interpol).created_by?('12345678')
    
    get :new, :album_id => albums(:kasabian)
    
    #assert_response :success
    #assert_template 'new'
  end
  
  def test_new_friends_album
    login_user('55556666')
    assert !albums(:interpol).created_by?('55556666')
    CommentController.any_instance.stubs(:friend_of_user?).returns(true)
    
    get :new, :album_id => albums(:kasabian)
    
    assert_response :success
    #assert_template 'new'
  end
  
  def test_new_strangers_album
    login_user('55556666')
    assert !albums(:interpol).created_by?('55556666')
    CommentController.any_instance.stubs(:friend_of_user?).returns(false)
    
    get :new, :album_id => albums(:kasabian)
    
    assert_response :success
    assert_template 'site/_error_404'
  end
  
  #
  # create
  #
  
  def test_create_own_album
    login_user('12345678')
    assert albums(:interpol).created_by?('12345678')
    comment_count = Comment.count
    CommentController.any_instance.stubs(:feed_publish).returns(true)
    
    post :create, :album_id => albums(:interpol).id, :comment => { :body => "I love it!" }
    
    #assert_response :redirect
    #assert_redirected_to :controller => 'album', :action => 'show', :id => albums(:interpol)
    
    assert_equal comment_count+1, Comment.count
    comment = Comment.find(:first, :order => "id DESC")
    assert_equal 12345678, comment.created_by
  end
  
  def test_create_friends_album
    login_user('55556666')
    assert !albums(:interpol).created_by?('55556666')
    comment_count = Comment.count
    CommentController.any_instance.stubs(:friend_of_user?).returns(true)
    CommentController.any_instance.stubs(:feed_publish).returns(true)
    
    post :create, :album_id => albums(:interpol).id, :comment => { :body => "I love it!" }
    
    #assert_response :redirect
    #assert_redirected_to :controller => 'album', :action => 'show', :id => albums(:interpol)
    
    assert_equal comment_count+1, Comment.count
    comment = Comment.find(:first, :order => "id DESC")
    assert_equal 55556666, comment.created_by
  end
  
  def test_create_strangers_album
    login_user('55556666')
    assert !albums(:interpol).created_by?('55556666')
    comment_count = Comment.count
    CommentController.any_instance.stubs(:friend_of_user?).returns(false)
    
    post :create, :album_id => albums(:interpol).id, :comment => { :body => "I love it!" }
    
    assert_response :success
    assert_template 'site/_error_404'
    
    assert_equal comment_count, Comment.count
  end
  
  def test_create_error
    login_user('12345678')
    comment_count = Comment.count
    
    post :create, :album_id => albums(:interpol).id, :comment => { }
    
    #assert_response :success
    #assert_template 'new'
    
    assert_equal comment_count, Comment.count
  end
  
  def test_create_get
    login_user('12345678')
    comment_count = Comment.count
    
    get :create, :album_id => albums(:interpol).id, :comment => { :body => "I love it!" }
    
    #assert_response :redirect
    #assert_redirected_to :controller => 'album', :action => 'list'
    
    assert_equal comment_count, Comment.count
  end
  
  #
  # delete
  #
  
  def test_delete
    login_user('12345678')
    assert comments(:interpol_answer).created_by?('12345678')
    
    get :delete, :id => comments(:interpol_answer)
    
    #assert_response :success
    #assert_template 'delete'
    
    assert_equal comments(:interpol_answer), assigns(:comment)
  end
  
  def test_delete_not_creator
    login_user('55556666')
    assert !comments(:interpol_answer).created_by?('55556666')
    
    get :delete, :id => comments(:interpol_answer)
    
    assert_response :success
    assert_template 'site/_error_404'
  end
  
  #
  # destroy
  #
  
  def test_destroy
    login_user('12345678')
    assert comments(:interpol_answer).created_by?('12345678')
    comment_count = Comment.count
    my_count = albums(:interpol).comments.size
    assert_equal comment_count, my_count
    
    post :destroy, :id => comments(:interpol_answer)
    
    #assert_response :redirect
    #assert_redirected_to :controller => 'album', :action => 'show', :id => albums(:interpol)
    
    comments(:interpol_answer).reload
    assert_not_nil comments(:interpol_answer).deleted_at
    
    assert_equal comment_count, Comment.count
    assert_equal my_count-1, albums(:interpol).comments.size
  end
  
  def test_destroy_not_creator
    login_user('55556666')
    assert !comments(:interpol_answer).created_by?('55556666')
    comment_count = Comment.count
    my_count = albums(:interpol).comments.size
    assert_equal comment_count, my_count
    
    post :destroy, :id => comments(:interpol_answer)
    
    assert_response :success
    assert_template 'site/_error_404'
    
    assert_equal comment_count, Comment.count
    assert_equal my_count, albums(:interpol).comments.size
  end
  
  def test_destroy_get
    login_user('12345678')
    comment_count = Comment.count
    my_count = albums(:interpol).comments.size
    assert_equal comment_count, my_count
    
    get :destroy, :id => comments(:interpol_answer)
    
    #assert_response :redirect
    #assert_redirected_to :controller => 'album', :action => 'list'
    
    comments(:interpol_answer).reload
    assert_nil comments(:interpol_answer).deleted_at
    
    assert_equal comment_count, Comment.count
    assert_equal my_count, albums(:interpol).comments.size
  end

end
