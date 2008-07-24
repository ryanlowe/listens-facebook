class MonitoredRecord < ActiveRecord::Base
  set_table_name nil #set this in subclasses
  
  def after_create
    a = AddAction.new
    a.monitorable_type = self.class.name
    a.monitorable_id = self.id
    a.valid?
    print a.errors.full_messages.join(",")
    a.save_or_raise "Couldn't save AddAction"
  end
  
end