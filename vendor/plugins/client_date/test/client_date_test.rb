require 'test/unit'
require File.dirname(__FILE__) + '/../lib/client_date'

class ClientDateTest < Test::Unit::TestCase
  include ClientDate

  def test_date_params
    assert_equal "", date_params(nil)
    assert_equal "2000,1,1,20,15", date_params(Time.gm(2000,"jan",1,20,15,1))
  end
  
  def test_format_date
    assert_equal "", format_date(nil)
    assert_equal "<script>fd(2000,1,1,20,15);</script>", format_date(Time.gm(2000,"jan",1,20,15,1))
  end
  
  def test_format_datetime
    assert_equal "", format_datetime(nil)
    assert_equal "<script>fdt(2000,1,1,20,15);</script>", format_datetime(Time.gm(2000,"jan",1,20,15,1))
  end
end