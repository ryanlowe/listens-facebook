class AlbumController < ApplicationController
  layout "owner"
  helper :listen
  helper :public
  
  before_filter :require_added_fb_app
  before_filter :require_logged_in_to_fb_app

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @albums = Album.find_all_by(facebook.user)
    @rated = Album.find_all_rated_by(facebook.user)
    @uid = facebook.user
    @title = "Listens - My Albums"
    @my_albums_selected = "selected='true'"
    render :layout => 'dashboard'
  end
  
  def show
    @album = Album.find(params[:id])
    bounce and return unless @album.created_by?(facebook.user)
    @listen = Listen.new(:album_id => @album.id)
    @uid = facebook.user
    @comment = Comment.new({ :album_id => @album.id })
    @omit_add_comment_cancel = true
    @title = "Listens - My Album"
    render :layout => 'plain'
  end
  
  def new
    @album = Album.new
    @uid = facebook.user
    @title = "Add an Album"
    render :layout => 'plain_header'
  end
  
  def create
    @album = Album.new(params[:album])
    @album.created_by = facebook.user
    if @album.save
      facebook_redirect_to :action => 'show', :id => @album
    else
      @uid = facebook.user
      @title = "Listens - Add an Album"
      @errors = (@album.errors.full_messages.join(' and '))+"."
      render :action => 'new'
    end
  end
  
  def edit
    @album = Album.find(params[:id])
    bounce and return unless @album.created_by?(facebook.user)
    @uid = facebook.user
    @title = "Edit Album"
    render :layout => 'plain_header'
  end
  
  def update
    @album = Album.find(params[:id])
    bounce and return unless @album.created_by?(facebook.user)
    if @album.update_attributes(params[:album])
      facebook_redirect_to :action => 'show', :id => @album
    else
      @uid = facebook.user
      @title = "Listens - Edit an Album"
      @errors = (@album.errors.full_messages.join(' and '))+"."
      render :action => 'edit'
    end
  end
  
  def delete
    @album = Album.find(params[:id])
    bounce and return unless @album.created_by?(facebook.user)
    @uid = facebook.user
    @title = "Listens - Delete "+@album.to_s+"?"
  end
  
  def destroy
    @album = Album.find(params[:id])
    bounce and return unless @album.created_by?(facebook.user)
    @album.destroy
    facebook_redirect_to :action => 'list'
  end
end
