require 'test_helper'

class PageletsHelperTest < ActionView::TestCase
  include PageletsHelper

  setup do
    controller.prepend_view_path File.expand_path('../../../static_fixtures/views', __FILE__)
  end

  teardown do
    Pagelets::Manager.clear
  end

  def action_name
    "test"
  end

  test "should find pagelets for page and mountpoint" do
    Pagelets::Manager.add_pagelet("test/test", :main_tabs,
                                               :name => "Name",
                                               :partial => "test")
    Pagelets::Manager.add_pagelet("smart_proxies/show", :main_tabs,
                                                       :name => "My name",
                                                       :partial => "test")
    pagelets = pagelets_for(:main_tabs)
    assert pagelets.any? { |p| p.name == "Name" }
    refute pagelets.any? { |p| p.name == "My name"}
  end

  test "should show appropriate tab headers" do
    Pagelets::Manager.add_pagelet("test/test", :main_tabs,
                                               :name => "Visible",
                                               :partial => "test",
                                               :onlyif => Proc.new { true })
    Pagelets::Manager.add_pagelet("test/test", :main_tabs,
                                               :name => "Hidden",
                                               :partial => "test",
                                               :onlyif => Proc.new { false })
    result = render_tab_header_for :main_tabs
    assert result.match /Visible/
    refute result.match /Hidden/
  end

  test "show page renders basic pagelets" do
    Pagelets::Manager.add_pagelet("test/test", :main_tabs,
                                                        :name => "TestTab",
                                                        :partial => "test")
    result = render_tab_content_for :main_tabs
    assert result.match /This is test partial/
  end

  test "show page renders correct id for pagelet" do
    Pagelets::Manager.add_pagelet("test/test", :main_tabs,
                                                        :name => "TestTab",
                                                        :partial => "test",
                                                        :id => "my-special-id")
    result = render_tab_content_for :main_tabs
    assert result.match /id='my-special-id'/
  end
end
