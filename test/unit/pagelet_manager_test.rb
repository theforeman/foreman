require 'test_helper'

class PageletManagerTest < ActiveSupport::TestCase
  test 'should assign default priority' do
    ::Pagelets::Manager.add_pagelet("test", :test_point, :partial => "tests")
    assert_equal 100, ::Pagelets::Manager.pagelets_at("test", :test_point).first.priority
  end

  test 'should add default priority' do
    ::Pagelets::Manager.add_pagelet("test", :point, :partial => "tests")
    ::Pagelets::Manager.add_pagelet("test", :point, :partial => "tests")

    assert_equal 100, ::Pagelets::Manager.pagelets_at("test", :point).sort.first.priority
    assert_equal 200, ::Pagelets::Manager.pagelets_at("test", :point).sort.last.priority
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
