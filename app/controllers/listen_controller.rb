class ListenController < ApplicationController
  layout "owner"
  helper :album
  helper :public
  
  before_filter :require_added_fb_app
  before_filter :require_logged_in_to_fb_app

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :controller => 'listen', :action => 'list' }

  def list
    @uid = facebook.user
    @listens = Listen.find_all_by(@uid, { :limit => 20 })
    @friend_listens = Listen.find_all_by_many(friends, { :limit => 20 })
    @my_listens_selected = "selected='true'"
    render :layout => 'dashboard'
  end

  def new
    @album = Album.find(params[:album_id])
    bounce and return unless @album.created_by?(facebook.user)
    @listen = Listen.new
    @uid = facebook.user
    update_profile
    @title = "Listens - Add a Past Listen"
    render :layout => 'plain_header'
  end

  def create
    @album = Album.find(params[:album_id])
    bounce and return unless @album.created_by?(facebook.user)
    @listen = Listen.new(params[:listen])
    @listen.album_id = @album.id
    @listen.created_by = facebook.user
    if @listen.save
      update_profile
      feed_publish @listen
      facebook_redirect_to :controller => 'album', :action => 'show', :id => @listen.album_id
    else
      render :action => 'new'
    end
  end

  def delete
    @listen = Listen.find(params[:id])
    bounce and return unless @listen.created_by?(facebook.user)
    @uid = facebook.user
    @title = "Listens - Delete this Listen?"
  end

  def destroy
    @listen = Listen.find(params[:id])
    bounce and return unless @listen.created_by?(facebook.user)
    @listen.destroy
    update_profile
    facebook_redirect_to :controller => 'album', :action => 'show', :id => @listen.album_id
  end
  
  protected
  
    def friends
      return [] if params[:fb_sig_friends].nil?
      params[:fb_sig_friends].split(',')
    end
  
    def update_profile
      @uid = facebook.user
      @listens = Listen.find_all_by(@uid, { :limit => 20 })
      profile_box = render_to_string({ :partial => 'profile/wide', :layout => false })
      facebook.fb_profile_set_FBML({:markup => profile_box, :uid => @uid})      
    end
    
    def feed_publish(listen)
      url = 'http://apps.facebook.com'+url_for(:controller => 'public', :action => 'album', :id => listen.album, :only_path => true)
      link = '<a href="'+url+'">'+listen.album.to_s+'</a>'
      text = '<fb:name uid="'+listen.created_by.to_s+'" firstnameonly="true" useyou="false"/> listened to '
      text += link
      text += "."
      facebook.fb_feed_publish_action_of_user({:title => text})
    end
    
end
