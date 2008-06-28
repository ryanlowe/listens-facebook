require File.dirname(__FILE__) + '/../test_helper'

class ListenTest < ActiveSupport::TestCase
  fixtures :albums, :listens
  
  def test_fixtures
    assert listens(:interpol_past).valid?
    assert listens(:interpol_now).valid?
  end
  
  def test_listen_to_others_album
    assert_equal 12345678, albums(:interpol).created_by
    
    l = Listen.new
    l.created_by = 33884466
    l.album_id = albums(:interpol).id
    assert !l.valid?
    
    l.created_by = 12345678
    assert l.valid?
    assert l.save
  end
end
