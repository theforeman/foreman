require 'test_helper'

class ViewItemTest < ActiveSupport::TestCase
  setup do
    @page = Pages::Page.new({:controller => :tests, :action => :test_action}, "fakes/show", 1)
  end

  test 'should create page with default values' do
    assert_equal 1, @page.columns.count
    assert_equal "tests/test_action".to_sym, @page.name
  end

  test 'shows snake cased name for tab' do
    tab = Pages::Tab.new(:"test tab", 25, 1)
    assert_equal "test_tab", tab.snake_name
  end

  test 'should add tab to view item' do
    @page.add_tab :name => :test_tab
    assert_equal 1, @page.tabs.count
    assert_equal 1, @page.tabs.values.first.columns.count
    assert_equal 19, @page.tabs.values.first.priority
  end

  test 'should not add tab with the same name' do
    @page.add_tab :name => :test_tab
    assert_raises RuntimeError do
      @page.add_tab :name => :test_tab
    end
  end

  test 'should not add tab without name' do
    @page.add_tab :name => :test_tab
    assert_raises RuntimeError do
      @page.add_tab({})
    end
  end

  test 'should not add tabs where there are already columns on page' do
    page = Pages::Page.new({:controller => :tests, :action => :another_test_action}, "fakes/show", 2)
    assert_raises RuntimeError do
      page.add_tab :name => :test_tab
    end
  end

  test 'should add widget to the default column' do
    @page.add_widget :name => :cool_widget, :partial => "widgets/cool_widget"
    assert_equal 1, @page.columns.first.widgets.count
  end

  test 'should add widget to specified column' do
    page = Pages::Page.new({:controller => :tests, :action => :another_test_action}, "fakes/show", 4)
    page.add_widget :name => :cool_widget, :partial => "widgets/cool_widget", :column => 2
    page.columns.each_with_index do |col, index|
      index == 2 ? assert_equal(1, col.widgets.count) : assert_equal(0, col.widgets.count)
    end
  end

  test 'should sort tabs by priority' do
    @page.add_tab :name => :top, :priority => 20
    @page.add_tab :name => :low, :priority => 10
    @page.add_tab :name => :medium, :priority => 15
    assert_equal :top, @page.sorted_tabs.values.first.name
    assert_equal :low, @page.sorted_tabs.values.last.name
  end

  test 'should find tab by name' do
    @page.add_tab :name => :test_tab
    assert @page.find_tab :test_tab
  end

  test 'should find nested tab by name' do
    @page.add_tab :name => :test_tab do |tab|
      tab.add_tab :name => :nested_tab
    end
    assert @page.find_tab :nested_tab
  end
end
