require 'test_helper'

class PageletManagerTest < ActiveSupport::TestCase
  let(:manager) { ::Pagelets::Manager.new }

  test '.add_pagelet uses instance' do
    Pagelets::Manager.instance.expects(:add_pagelet).with('key', 'mount', {})
    Pagelets::Manager.add_pagelet('key', 'mount', {})
  end

  test '.pagelets_at uses instance' do
    Pagelets::Manager.instance.expects(:pagelets_at).with('key', 'mount').returns([:test])
    assert_equal [:test], Pagelets::Manager.pagelets_at('key', 'mount')
  end

  test '#add_pagelet assigns default priority' do
    manager.add_pagelet("test", :test_point, :partial => "tests")
    assert_equal 100, manager.pagelets_at("test", :test_point).first.priority
  end

  test '#add_pagelet increments default priority' do
    manager.add_pagelet("test", :point, :partial => "tests")
    manager.add_pagelet("test", :point, :partial => "tests")

    assert_equal 100, manager.pagelets_at("test", :point).min.priority
    assert_equal 200, manager.pagelets_at("test", :point).max.priority
  end

  test '#add_pagelet should raise error when partial is missing' do
    assert_raise Foreman::Exception do
      manager.add_pagelet('test', :mountpoint, {})
    end
  end

  test '#add_pagelet should raise error when mountpoint is nil' do
    assert_raise Foreman::Exception do
      manager.add_pagelet('test', nil, {:partial => 'test'})
    end
  end

  test '#clear removes all pagelets' do
    manager.add_pagelet("test", :point, :partial => "original")
    manager.clear
    assert_equal [], manager.pagelets_at("test", :point)
  end

  test '#dup fully isolates pagelet state' do
    pagelet = manager.add_pagelet("test", :point, :partial => "original")
    assert_equal [pagelet], manager.pagelets_at("test", :point)

    new_manager = manager.dup
    new_pagelet1 = new_manager.pagelets_at("test", :point).first
    assert_equal pagelet.partial, new_pagelet1.partial

    new_pagelet2 = new_manager.add_pagelet("test", :point, :partial => "another")
    assert_equal [new_pagelet1, new_pagelet2], new_manager.pagelets_at("test", :point)
    assert_equal [pagelet], manager.pagelets_at("test", :point)
  end

  context '#with_key' do
    test '#add_pagelet registers without key' do
      pagelet = manager.with_key('test') { |mgr| mgr.add_pagelet(:point, partial: 'original') }
      assert_equal [pagelet], manager.pagelets_at('test', :point)
    end

    test '#pagelets_at retrieves without key' do
      pagelet = manager.add_pagelet('test', :point, partial: 'original')
      assert_equal [pagelet], manager.with_key('test') { |mgr| mgr.pagelets_at(:point) }
    end
  end
end
