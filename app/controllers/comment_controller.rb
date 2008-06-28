class CommentController < ApplicationController
  layout "public"
  helper :album
  helper :public
  
  before_filter :require_logged_in_to_fb_app

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :controller => 'album', :action => 'list' }

  def list
    @sent = Comment.find_all_by(facebook.user, { :limit => 20 })
    @received = Comment.find_all_on_albums_by(facebook.user, { :limit => 20 })
    @uid = facebook.user
    @title = "Listens - My Comments"
    @my_comments_selected = "selected='true'"
    render :layout => 'dashboard'
  end

  def new
    @album = Album.find(params[:album_id])
    bounce and return unless friend_of_user?(@album.created_by)
    @comment = Comment.new
    @uid = @album.created_by
  end

  def create
    @album = Album.find(params[:album_id])
    bounce and return unless friend_of_user?(@album.created_by)
    @comment = Comment.new(params[:comment])
    @comment.album_id = @album.id
    @comment.created_by = facebook.user
    if @comment.save
      feed_publish @comment
      #send_email @comment
      facebook_redirect_to :controller => 'public', :action => 'album', :id => @comment.album_id
    else
      @uid = @album.created_by
      render :action => 'new'
    end
  end

  def delete
    @comment = Comment.find(params[:id])
    bounce and return unless @comment.created_by?(facebook.user)
    @uid = @comment.created_by
    @title = "Delete this Comment?"
    render :layout => "owner"
  end

  def destroy
    @comment = Comment.find(params[:id])
    bounce and return unless @comment.created_by?(facebook.user)
    @comment.destroy
    facebook_redirect_to :controller => 'public', :action => 'album', :id => @comment.album_id
  end
  
  protected
  
    def feed_publish(comment)
      url = 'http://apps.facebook.com'+url_for(:controller => 'public', :action => 'album', :id => comment.album, :only_path => true)
      link = '<a href="'+url+'">'+comment.album.to_s+'</a>'
      text = '<fb:name uid="'+comment.created_by.to_s+'" firstnameonly="true" useyou="false"/> commented on'
      if comment.on_own_album?
        text += ' <fb:pronoun uid="'+comment.created_by.to_s+'" useyou="false" usethey="false" possessive="true"/>' # his/her/your/their
      else
        text += ' <fb:name uid="'+comment.album.created_by.to_s+'" useyou="false" possessive="true"/>'
      end
      text += ' album '
      text += link
      text += "."
      facebook.fb_feed_publish_action_of_user({:title => text})
    end
    
    def send_email(comment)
      return if comment.on_own_album?
      uid = facebook.user
      url = 'http://apps.facebook.com'+url_for(:controller => 'public', :action => 'album', :id => comment.album, :only_path => true)
      
      user_info = facebook.fb_users_get_info({ :uids => uid.to_s, :fields => "first_name, last_name" })
      commenter = user_info.to_s
      
      text  = '<p><fb:name uid="'+comment.created_by.to_s+'" firstnameonly="true" linked="false" useyou="false"/>'
      text += ' commented on your album '+comment.album.to_s+'</p>'
      text += '<p>To read all the comments, follow the link below:</p>'
      text += '<p>'+url+'</p>'
      
      params = {}
      params[:recipients] = comment.album.created_by.to_s 
      params[:subject] = commenter+" has commented on your album" 
      params[:fbml] = text
      facebook.fb_notifications_send_email(params)
    end
    
#<?xml version=\"1.0\" encoding=\"UTF-8\"?>
#<users_getInfo_response xmlns=\"http://api.facebook.com/1.0/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd\" list=\"true\">
#  <user>
#    <uid>751900388</uid>
#    <first_name>Jon</first_name>
#    <last_name>Lowe</last_name>
#  </user>
#</users_getInfo_response>
  
end
