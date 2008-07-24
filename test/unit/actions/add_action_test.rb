require File.dirname(__FILE__) + '/../../test_helper'

class AddActionTest < ActiveSupport::TestCase
  fixtures :albums, :listens, :actions
  
  def test_new_album
    album_count = Album.count
    action_count = Action.count
    
    a = Album.new
    a.created_by = 12345678
    a.artist = "Justice"
    a.title = "Cross"
    assert a.valid?
    assert a.save
    
    assert_equal album_count+1, Album.count
    assert_equal action_count+1, Action.count
    
    aa = AddAction.find(:first, :order => "id DESC")
    
    assert_equal a, aa.monitorable
    assert_equal 12345678, aa.done_by
    assert_not_nil aa.done_at
    assert !aa.feed_queued # new albums don't show up in the news feed
    assert_nil aa.feed_published_at
  end
  
  def test_new_listen
    listen_count = Listen.count
    action_count = Action.count
    
    l = Listen.new
    l.created_by = 12345678
    l.album = albums(:interpol)
    assert l.valid?
    assert l.save
    
    assert_equal listen_count+1, Listen.count
    assert_equal action_count+1, Action.count
    
    aa = AddAction.find(:first, :order => "id DESC")
    
    assert_equal l, aa.monitorable
    assert_equal 12345678, aa.done_by
    assert_not_nil aa.done_at
    assert aa.feed_queued
    assert_nil aa.feed_published_at
  end
  
  def test_new_comment
    comment_count = Comment.count
    action_count = Action.count
    
    c = Comment.new
    c.created_by = 12345678
    c.album = albums(:interpol)
    c.body = "Yo!"
    assert c.valid?
    assert c.save
    
    assert_equal comment_count+1, Comment.count
    assert_equal action_count+1, Action.count
    
    aa = AddAction.find(:first, :order => "id DESC")
    
    assert_equal c, aa.monitorable
    assert_equal 12345678, aa.done_by
    assert_not_nil aa.done_at
    assert aa.feed_queued
    assert_nil aa.feed_published_at
  end

  def test_new_review
    review_count = Review.count
    action_count = Action.count
    
    r = Review.new
    r.created_by = 12345678
    r.album = albums(:interpol)
    r.body = "Yo!"
    assert r.valid?
    assert r.save
    
    assert_equal review_count+1, Review.count
    assert_equal action_count+1, Action.count
    
    aa = AddAction.find(:first, :order => "id DESC")
    
    assert_equal r, aa.monitorable
    assert_equal 12345678, aa.done_by
    assert_not_nil aa.done_at
    assert aa.feed_queued
    assert_nil aa.feed_published_at
  end
  
end
