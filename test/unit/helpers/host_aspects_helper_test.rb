require 'test_helper'
require 'aspect_test_helper'

class HostAspectsHelperTest < ActionView::TestCase
  class TestAspect < HostAspectBase
  end

  include HostAspectsHelper

  context 'aspects related' do
    setup do
      @aspect_model = TestAspect.new
      @host = mock('host')
      @aspect_config = HostAspects::Entry.new(:test_aspect, 'HostAspectsHelperTest::TestAspect')
      @host.stubs(:host_aspects_with_definitions).returns({ @aspect_model => @aspect_config })
    end

    test '#load_tabs returns hash of aspects' do
      tabs = load_aspects(@host)

      assert_equal @aspect_model, tabs[:test_aspect]
    end

    test '#helper_tabs returns hash if hash specified' do
      @aspect_config.tabs = {:my_new_tab => 'my/tab/template.html.erb'}
      tabs = helper_tabs(@host)

      assert_equal 'my/tab/template.html.erb', tabs[:my_new_tab]
    end

    test '#helper_tabs returns hash if method specified' do
      expects(:my_tabs_method).returns({:my_new_tab => 'my/tab/template.html.erb'})
      @aspect_config.tabs = :my_tabs_method
      tabs = helper_tabs(@host)

      assert_equal 'my/tab/template.html.erb', tabs[:my_new_tab]
    end
  end
end
