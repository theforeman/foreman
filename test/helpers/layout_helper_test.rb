require 'test_helper'

class LayoutHelperTest < ActionView::TestCase
  include LayoutHelper
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

  test "table css classes should return the regular classes for table" do
    assert_equal table_css_classes, "pf-c-table pf-m-compact "
  end

  test "table css classes should return the regular classes for table plus the added classes" do
    assert_equal table_css_classes("test-class"), "pf-c-table pf-m-compact test-class"
  end

  test "breadcrumbs are not mounted on non-ok pages" do
    response.stubs(:ok?).returns(false)
    expects(:react_component).never

    mount_breadcrumbs
  end

  test "breadcrumbs are not mounted on welcome pages" do
    @welcome = true
    expects(:react_component).never

    mount_breadcrumbs
  end
end
