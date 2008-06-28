require File.dirname(__FILE__) + '/../test_helper'

class ReviewTest < ActiveSupport::TestCase
  fixtures :albums, :reviews
  
  def test_fixtures
    assert reviews(:kasabian).valid?
  end
  
  def test_review_dupe
    assert_equal reviews(:kasabian), albums(:kasabian).review
    assert_equal nil, albums(:interpol).review
    
    r = Review.new
    r.created_by = 12345678
    r.album_id = albums(:kasabian).id
    r.body = "I love this album toooo!"
    
    assert !r.valid?
    
    #change to an album this person hasn't reviewed yet
    r.album_id = albums(:interpol).id
    
    assert r.valid?
    assert r.save
  end
  
  def test_review_after_destroy
    assert_equal reviews(:kasabian), albums(:kasabian).review
    reviews(:kasabian).destroy
    albums(:kasabian).reload
    assert_equal nil, albums(:kasabian).review
  
    r = Review.new
    r.created_by = 12345678
    r.album_id = albums(:kasabian).id
    r.body = "I love this album toooo!"
    assert r.valid?
    assert r.save
  end
  
  def test_review_others
    assert_equal 12345678, albums(:interpol).created_by 
    
    r = Review.new
    r.created_by = 55556666
    r.album_id = albums(:interpol).id
    r.body = "I love this album toooo!"
    
    assert !r.valid?
    
    # change to the person that created this album
    r.created_by = 12345678
    
    assert r.valid?
    assert r.save
  end
end
