module ClientDate
  def format_date(date)
    return "" if date.nil?
    "<script>fd("+date_params(date)+");</script>"
  end
  
  def format_datetime(date)
    return "" if date.nil?
    "<script>fdt("+date_params(date)+");</script>"
  end
  
  def date_params(date)
    return "" if date.nil?
    text  = date.year.to_s + ","
    text += date.month.to_s + ","
    text += date.day.to_s + ","
    text += date.hour.to_s + ","
    text += date.min.to_s
    text
  end
end