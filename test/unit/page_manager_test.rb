require 'test_helper'

class PageManagerTest < ActiveSupport::TestCase
  test 'should find page' do
    Pages::Manager.add_page({ :controller => :tests, :action => :show }, "tests/show")
    assert Pages::Manager.find_page(:tests, :show)
  end

  test 'should yield page for extension' do
    Pages::Manager.add_page({ :controller => :tests, :action => :show_1 }, "tests/show")
    Pages::Manager.extend_page({ :controller => :tests, :action => :show_1 }) do |page|
      assert_kind_of  Pages::Page, page
    end
  end

  test 'should yield tab for extension' do
    Pages::Manager.add_page({ :controller => :tests, :action => :show_2 }, "tests/show")
    Pages::Manager.extend_page({ :controller => :tests, :action => :show_2 }) do |page|
      page.add_tab(:name => :test_tab) do |tab|
        assert_kind_of  Pages::Tab, tab
      end
    end
  end
end
