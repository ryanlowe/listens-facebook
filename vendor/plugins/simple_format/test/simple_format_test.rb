require 'test/unit'
require File.dirname(__FILE__) + '/../lib/simple_format'

class SimpleFormatTest < Test::Unit::TestCase

  def test_corner_inputs
    assert_equal "", SimpleFormat.format(nil)
    assert_equal "", SimpleFormat.format("")
    assert_equal "42", SimpleFormat.format(42)
  end

  #
  # line breaks
  #
  
  def test_format_line_breaks
    assert_equal "", SimpleFormat.format("\n")
    assert_equal "hello", SimpleFormat.format("hello\n")
    assert_equal "world!", SimpleFormat.format("\nworld!")
    
    assert_equal "hello<br/>\nworld!", SimpleFormat.format("hello\nworld!")
    assert_equal "hello<br/>\n<br/>\nworld!", SimpleFormat.format("hello\n\nworld!")
    assert_equal "hello<br/>\n<br/>\n<br/>\nworld!", SimpleFormat.format("hello\n\n\nworld!")
  end
  
  def test_format_line_breaks
    assert_equal "", SimpleFormat.format("\n", false)
    assert_equal "hello", SimpleFormat.format("hello\n", false)
    assert_equal "world!", SimpleFormat.format("\nworld!", false)
    
    assert_equal "hello world!", SimpleFormat.format("hello\nworld!", false)
    assert_equal "hello  world!", SimpleFormat.format("hello\n\nworld!", false)
    assert_equal "hello   world!", SimpleFormat.format("hello\n\n\nworld!", false)
  end
  
  #
  # tabs
  # 
  
  def test_format_tabs
    assert_equal '<span class="tab">&nbsp;</span>', SimpleFormat.tab
    
    assert_equal "", SimpleFormat.format("\t")
    assert_equal "hello", SimpleFormat.format("hello\t")
    assert_equal "world!", SimpleFormat.format("\tworld!")
    
    #tab beginning of line is replaced with non-breaking spaces
    assert_equal "hello<br/>\n"+SimpleFormat.tab+"world!", SimpleFormat.format("hello\n\tworld!")
    assert_equal "hello<br/>\n"+SimpleFormat.tab+"world!", SimpleFormat.format("hello\n \tworld!")
    #except on a blank line
    assert_equal "something<br/>\n<br/>\nanother", SimpleFormat.format("something\n\t\nanother")
    
    #tab middle of line is replaced with a soft space
    assert_equal "hello world!", SimpleFormat.format("hello\tworld!")
    assert_equal "hello  world!", SimpleFormat.format("hello\t\tworld!")
    assert_equal "hello   world!", SimpleFormat.format("hello \t\tworld!")
    
    original = "Source Information:\n"+
               " \tDwelling  \tWalters Cottage Robertsbridge Rd\n"+
               " \tCensus Place\tMountfield, Sussex, England\n"+
               " \tFamily History Library Film  \t1341245"
    expected = "Source Information:<br/>\n"+
               SimpleFormat.tab+"Dwelling   Walters Cottage Robertsbridge Rd<br/>\n"+
               SimpleFormat.tab+"Census Place Mountfield, Sussex, England<br/>\n"+
               SimpleFormat.tab+"Family History Library Film   1341245"
    assert_equal expected, SimpleFormat.format(original)
  end
  
  #
  # urls
  #
  
  def test_format_url_domain
    url = "http://www.fanconcert.com"
    assert_equal '<a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format(url)
    assert_equal 'Go here: <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format("Go here: "+url)
    assert_equal '<a class="external" href="'+url+'" title="'+url+'">'+url+'</a> is cool!', SimpleFormat.format(url+" is cool!")
    assert_equal 'I really like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a> a lot!', SimpleFormat.format("I really like "+url+" a lot!")
    assert_equal 'I really like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format("I really like "+url+"\n")
  end
  
  def test_format_url_secure_domain
    url = "https://www.fanconcert.com"
    assert_equal '<a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format(url)
    assert_equal 'Go here: <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format("Go here: "+url)
    assert_equal '<a class="external" href="'+url+'" title="'+url+'">'+url+'</a> is cool!', SimpleFormat.format(url+" is cool!")
    assert_equal 'I really like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a> a lot!', SimpleFormat.format("I really like "+url+" a lot!")
    assert_equal 'I really like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format("I really like "+url+"\n")
  end
  
  def test_format_url_directory
    url = "http://www.fanconcert.com/search/"
    assert_equal '<a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format(url)
    assert_equal 'Go here: <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format("Go here: "+url)
    assert_equal '<a class="external" href="'+url+'" title="'+url+'">'+url+'</a> is cool!', SimpleFormat.format(url+" is cool!")
    assert_equal 'I really like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a> a lot!', SimpleFormat.format("I really like "+url+" a lot!")
    assert_equal 'I really like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format("I really like "+url+"\n")
  end
  
  def test_format_url_querystring
    url = "http://www.fanconcert.com/search/concerts?after=now&close_to=1&proximity=200&artist_tagged_by=1"
    assert_equal '<a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format(url)
    assert_equal 'Go here: <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format("Go here: "+url)
    assert_equal '<a class="external" href="'+url+'" title="'+url+'">'+url+'</a> is cool!', SimpleFormat.format(url+" is cool!")
    assert_equal 'I really like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a> a lot!', SimpleFormat.format("I really like "+url+" a lot!")
    assert_equal 'I really like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format("I really like "+url+"\n")
  end
  
  def test_format_url_page
    url = "http://www.normal.com/max.html"
    assert_equal '<a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format(url)
    assert_equal 'Go here: <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format("Go here: "+url)
    assert_equal '<a class="external" href="'+url+'" title="'+url+'">'+url+'</a> is cool!', SimpleFormat.format(url+" is cool!")
    assert_equal 'I really like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a> a lot!', SimpleFormat.format("I really like "+url+" a lot!")
    assert_equal 'I really like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>', SimpleFormat.format("I really like "+url+"\n")
  end
  
  def test_format_url_domain_ending_in_period
    url = "http://www.cnn.com"
    assert_equal 'I do not like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>.', SimpleFormat.format("I do not like "+url+".")
  end
  
  def test_format_url_domain_ending_in_punctuation
    url = "http://www.cnn.com"
    assert_equal 'I really like <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>!', SimpleFormat.format("I really like "+url+"!")
    assert_equal 'Have you been to <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>?', SimpleFormat.format("Have you been to "+url+"?")
  end
  
  def test_format_two_urls
    url = "http://www.cnn.com"
    assert_equal '<a class="external" href="'+url+'" title="'+url+'">'+url+'</a>? WTF is <a class="external" href="'+url+'" title="'+url+'">'+url+'</a>?', SimpleFormat.format(url+"? WTF is "+url+"?")
  end
  
#  def test_format_www
#    www_url = "www.cnn.com"
#    url = "http://"+www_url
#    assert_equal 'I really like <a class="external" href="'+url+'" title="'+www_url+'">'+www_url+'</a>', SimpleFormat.format("I really like "+www_url)
#  end
  
  #
  # escaping html
  #
  
  def test_escape_html
    assert_equal "&lt;b&gt;bold!&lt;/b&gt;", SimpleFormat.escape_html("<b>bold!</b>")
  end
end