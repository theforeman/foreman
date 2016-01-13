require 'test_helper'

class PageletManagerTest < ActiveSupport::TestCase
  test 'should assign default priority' do
    ::Pagelets::Manager.add_pagelet("test", :test_point, :partial => "tests")
    assert_equal 100, ::Pagelets::Manager.pagelets_at("test", :test_point).first.priority
  end

  test 'should return sorted pagelets at mountpoint' do
    assert_equal 0, ::Pagelets::Manager.sorted_pagelets_at("test", :mountpoint).count
    ::Pagelets::Manager.add_pagelet("test", :mountpoint, :partial => "tests", :priority => 20)
    ::Pagelets::Manager.add_pagelet("test", :mountpoint, :partial => "tests", :priority => 15)
    ::Pagelets::Manager.add_pagelet("test", :mountpoint, :partial => "tests", :priority => 5)
    assert_equal 3, ::Pagelets::Manager.sorted_pagelets_at("test", :mountpoint).count
    assert_equal 5, ::Pagelets::Manager.sorted_pagelets_at("test", :mountpoint).first.priority
  end

  test 'should add default priority' do
    ::Pagelets::Manager.add_pagelet("test", :point, :partial => "tests")
    ::Pagelets::Manager.add_pagelet("test", :point, :partial => "tests")

    assert_equal 100, ::Pagelets::Manager.sorted_pagelets_at("test", :point).first.priority
    assert_equal 200, ::Pagelets::Manager.sorted_pagelets_at("test", :point).last.priority
  end

  test '.add_pagelet should raise error when partial is missing' do
    assert_raise Foreman::Exception do
      Pagelets::Manager.add_pagelet('test', :mountpoint, {})
    end
  end

  test '.add_pagelet should raise error when mountpoint is nil' do
    assert_raise Foreman::Exception do
      Pagelets::Manager.add_pagelet('test', nil, {:partial => 'test'})
    end
  end
end
