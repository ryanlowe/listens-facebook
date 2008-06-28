require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  fixtures :albums, :listens, :comments

  def test_fixtures
    assert comments(:interpol_question).valid?
    assert comments(:interpol_answer).valid?
  end
  
  def test_blank_comments
    c = Comment.new
    c.album_id = albums(:interpol).id
    c.created_by = 12345678
    assert !c.valid?
    
    c.body = '     '
    assert !c.valid?
    
    c.body = 'Something.'
    assert c.valid?
    assert c.save
  end
end
