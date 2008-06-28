require File.dirname(__FILE__) + '/../test_helper'

class AlbumTest < ActiveSupport::TestCase
  fixtures :albums, :listens
  
  def test_fixtures
    assert albums(:kasabian).valid?
    assert albums(:interpol).valid?
  end
  
  def test_prevent_dupe1
    a = Album.new
    a.created_by = 12345678
    a.artist = "Interpol"
    a.title = "Our Love to Admire"
    assert !a.valid?
    
    a.created_by = 15007788 # different user can have this album
    assert a.valid?
    assert a.save
  end  
  
  def test_prevent_dupe2
    a = Album.new
    a.created_by = 12345678
    a.artist = "Interpol"
    a.title = "Our Love to Admire"
    assert !a.valid?

    a.title = "Antics"      # another title
    assert a.valid?
    assert a.save
  end
  
  def test_sorting_fields
    a = Album.new
    a.created_by = 12345678
    a.artist = "The Futureheads"
    a.title  = "The Futureheads"
    a.year = "2004"
    
    assert a.valid?
    assert a.save
    assert_equal "Futureheads", a.sorting_artist
    assert_equal "Futureheads", a.sorting_title
  end
  
  #
  # rating
  #
  
  def test_rating
    assert_equal 7.0,  albums(:kasabian).rating_numerator
    assert_equal 10.0, albums(:kasabian).rating_denominator
    assert_equal 0.7,  albums(:kasabian).rating
    
    albums(:kasabian).rating_numerator = 6.2
    assert albums(:kasabian).save
    
    albums(:kasabian).reload
    assert_equal 6.2, albums(:kasabian).rating_numerator
    assert_equal 10.0, albums(:kasabian).rating_denominator
    assert_equal 0.62, albums(:kasabian).rating
    assert_equal "6.2/10", albums(:kasabian).rating_to_s
    assert_equal "6.2/10", albums(:kasabian).rating_to_s_long
  end
  
  def test_clear_rating
    assert_equal 7.0,  albums(:kasabian).rating_numerator
    assert_equal 10.0, albums(:kasabian).rating_denominator
    assert_equal 0.7,  albums(:kasabian).rating
    
    albums(:kasabian).rating_numerator = nil
    albums(:kasabian).rating_denominator = nil
    assert albums(:kasabian).save
    
    albums(:kasabian).reload
    assert_equal nil, albums(:kasabian).rating_numerator
    assert_equal nil, albums(:kasabian).rating_denominator
    assert_equal nil, albums(:kasabian).rating
    assert_equal "", albums(:kasabian).rating_to_s
    assert_equal "Not rated", albums(:kasabian).rating_to_s_long
  end
  
  def test_not_rated
    assert_equal nil, albums(:interpol).rating
    
    assert_equal nil, albums(:interpol).rating
    assert_equal "",  albums(:interpol).rating_to_s
    assert_equal "Not rated", albums(:interpol).rating_to_s_long
    
    albums(:interpol).rating_numerator = 8.9
    assert albums(:interpol).save
    
    albums(:interpol).reload
    assert_equal nil, albums(:interpol).rating
    assert_equal "",  albums(:interpol).rating_to_s
    assert_equal "Not rated", albums(:interpol).rating_to_s_long
    
    albums(:interpol).rating_denominator = 10
    assert albums(:interpol).save
    
    albums(:interpol).reload
    assert_equal 0.89, albums(:interpol).rating
    assert_equal "8.9/10", albums(:interpol).rating_to_s
    assert_equal "8.9/10", albums(:interpol).rating_to_s_long
  end
  
  #
  # self.sorting_string
  #
  
  def test_self_sorting_string
    assert_equal "Brant House", Album.sorting_string("Brant House")
    assert_equal "A Totally Rad Place", Album.sorting_string("A Totally Rad Place")
    assert_equal "Theatre House", Album.sorting_string("Theatre House")
    # weird ones
    assert_equal "", Album.sorting_string(nil)
    assert_equal "37", Album.sorting_string(37)
    assert_equal "The", Album.sorting_string("The")
    assert_equal "TheThe", Album.sorting_string("TheThe")
    assert_equal "The", Album.sorting_string("The The")
    # starts with The
    assert_equal "Guvernment", Album.sorting_string("The Guvernment")
  end
end
