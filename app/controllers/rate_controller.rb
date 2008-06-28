class RateController < ApplicationController
  layout "plain_header"
  
  before_filter :require_added_fb_app
  before_filter :require_logged_in_to_fb_app

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :update ],
         :redirect_to => { :controller => :album, :action => :list }

  def album
    @album = Album.find(params[:id])
    bounce and return unless @album.created_by?(facebook.user)
    @uid = facebook.user
    @review = @album.review.body if @album.review
    @title = "Listens - Rate "+@album.to_s
  end

  def update
    @album = Album.find(params[:id])
    bounce and return unless @album.created_by?(facebook.user)
    if @album.update_attributes(params[:album])
      update_feed = Review.set_for(@album, params[:review])
      feed_publish(@album) if update_feed
      facebook_redirect_to :controller => 'album', :action => 'show', :id => @album
    else
      @uid = facebook.user
      @title = "Listens - Rate "+@album.to_s
      @errors = (@album.errors.full_messages.join(' and '))+"."
      @review = params[:review]
      render :action => 'album'
    end
  end
  
  protected
  
    def feed_publish(album)
      album.reload
      url = 'http://apps.facebook.com'+url_for(:controller => 'public', :action => 'album', :id => album, :only_path => true)
      link = '<a href="'+url+'">'+album.to_s+'</a>'
      text = '<fb:name uid="'+album.review.created_by.to_s+'" firstnameonly="true" useyou="false"/> reviewed '
      text += link
      text += " and gave it "+album.rating_to_s if album.rating_to_s.length > 1
      text += "."
      facebook.fb_feed_publish_action_of_user({:title => text})
    end
end
