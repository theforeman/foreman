require "test_helper"

class DisableTurbolinksTest < ActiveSupport::TestCase
  setup do
    DisableTurbolinks.register ["controller/action", "hosts/show"]
  end

  test "should register pages" do
    assert DisableTurbolinks.registered_pages.include? "controller/action"
  end

  test "should determine if page is registered" do
    assert DisableTurbolinks.include?({ :controller => "controller", :action => "action" })
  end

  test "should determine by paht if page is registered" do
    assert DisableTurbolinks.has_path? "/hosts/show"
  end

  test "should show registered pages" do
    assert_equal 2, DisableTurbolinks.registered_pages.count
  end
end
