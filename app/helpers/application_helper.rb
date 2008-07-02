# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def format_attribute(value, label=nil)
    return "" if value.nil? or value.to_s.length < 1
    return h(value.to_s)+"<br/>\n" if label.nil?
    ""+h(label.to_s)+": "+h(value.to_s)+"<br/>\n"
  end
  
  def string_date(datetime)
    return "" if datetime.nil?
    dt = datetime.in_time_zone
    dt.year.to_s+dt.month.to_s+dt.day.to_s
  end
  
  # def string_datetime(datetime)
  #   return "" if datetime.nil?
  #   dt = datetime.in_time_zone
  #   dt.year.to_s+dt.month.to_s+dt.day.to_s+"_"+dt.hour.to_s+dt.min.to_s
  # end
  
  def format_feed_date(datetime)
    return "" if datetime.nil?
    dt = datetime.in_time_zone
    #date = string_date(dt)
    #return "Today" if date == string_date(Time.now)
    #return "Yesterday" if date == string_date(1.day.ago)
    dt.strftime("%B %d") 
  end
  
  def link_person_name(uid)
    return "" if uid.nil?
    text = person_name(uid)
    link_to text, :controller => 'public', :action => 'listens', :uid => uid
  end
  
  def link_person_name_possessive(uid)
    return "" if uid.nil?
    text = person_name_possessive(uid)
    link_to text, :controller => 'public', :action => 'listens', :uid => uid
  end
  
  ### FBML shortcuts
  
  def facebook_datetime(datetime)
    return "" if datetime.nil?
    # time since epoch is in UTC
    "<fb:time t='"+datetime.to_i.to_s+"' tz='America/New_York'/>"
  end
  
  # <fb:name/>
  
  def person_name(uid)
    return "" if uid.nil?
    '<fb:name uid="'+uid.to_s+'" useyou="false" linked="false"/>'
  end
  
  def person_name_possessive(uid)
    return "" if uid.nil?
    '<fb:name uid="'+uid.to_s+'" useyou="false" linked="false" possessive="true"/>'
  end
  
  def person_first_name(uid)
    return "" if uid.nil?
    '<fb:name uid="'+uid.to_s+'" useyou="false" firstnameonly="true" linked="false"/>'
  end
  
  def person_first_name_possessive(uid)
    return "" if uid.nil?
    '<fb:name uid="'+uid.to_s+'" useyou="false" firstnameonly="true" linked="false" possessive="true"/>'
  end
  
end
