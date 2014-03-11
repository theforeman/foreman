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

end