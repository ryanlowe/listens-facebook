require File.dirname(__FILE__) + '/../../test_helper'

class ActionTest < ActiveSupport::TestCase
  fixtures :listens
  
  def test_truth
    assert true
  end
  
  def test_required_fields
    a = AddAction.new
    
    assert !a.valid?
    assert_equal 3, a.errors.size
    assert a.errors.on(:done_by)
    assert a.errors.on(:monitorable_type)
    assert a.errors.on(:monitorable_id)
    
    a.monitorable = listens(:interpol_past)
    
    assert a.valid?
    assert a.save
    
    assert_equal listens(:interpol_past), a.monitorable
  end
  
end
