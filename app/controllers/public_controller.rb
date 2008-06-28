class PublicController < ApplicationController
  layout "public"
  helper :album
  helper :listen

  def listens
    #bounce and return unless friend_of_user?(params[:uid])
    @listens = Listen.find_all_by(params[:uid], { :limit => 20 })
    @rotation_days = 90
    @rotation = Album.find_all_in_rotation_by(params[:uid], { :limit => 20, :days => @rotation_days })
    @listens_selected = "selected='true'"
    @uid = params[:uid]
  end

  def albums
    #bounce and return unless friend_of_user?(params[:uid])
    @albums = Album.find_all_by(params[:uid])
    @rated = Album.find_all_rated_by(params[:uid])
    @albums_selected = "selected='true'"
    @uid = params[:uid]
  end
  
  def album
    @album = Album.find(params[:id])
    #bounce and return unless friend_of_user?(@album.created_by)
    @uid = @album.created_by
    @comment = Comment.new({ :album_id => @album.id })
    @omit_add_comment_cancel = true
    @title = @album.to_s
  end
  
  def comments
    #bounce and return unless friend_of_user?(params[:uid])
    @max = 20
    @sent = Comment.find_all_by(params[:uid], { :limit => @max })
    @uid = params[:uid]
    @comments_selected = "selected='true'"
  end
  
  def recommends
    #bounce and return unless friend_of_user?(params[:uid])
    @given    = Album.find_all_recommended_by(params[:uid])
    @received = Album.find_all_recommended_to(params[:uid])
    @uid = params[:uid]
    @recommends_selected = "selected='true'"
  end

end
