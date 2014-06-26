require 'test_helper'

class LayoutHelperTest < ActionView::TestCase
  test "alert should be closable" do
    result = alert(:close => true)
    assert_include result, 'alert-dismissable'
    assert_include result, alert_close
  end

  test "alert should not be closeable" do
    result = alert(:close => false)
    assert_not_include result, 'alert-dismissable'
    assert_not_include result, alert_close
  end

  test "is_required?(f, attr) method returns true if attribute is required and false if not required" do
    f = ActionView::Helpers::FormBuilder.new(:hostgroup, Hostgroup.new, @hostgroup, {}, {})
    assert is_required?(f, :name)
    assert is_required?(f, :title)
    refute is_required?(f, :environment_id)
    refute is_required?(f, :parent_id)
  end

end
