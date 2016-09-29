require 'test_helper'

class PageletTest < ActiveSupport::TestCase
  test 'order pagelets asc' do
    pagelets = []
    pagelets << ::Pagelets::Pagelet.new("first", "tests/test", 40, {})
    pagelets << ::Pagelets::Pagelet.new("first", "tests/test", 50, {})
    pagelets << ::Pagelets::Pagelet.new("first", "tests/test", 10, {})
    pagelets << ::Pagelets::Pagelet.new("first", "tests/test", 20, {})
    pagelets = pagelets.sort

    assert_equal 10, pagelets[0].priority
    assert_equal 50, pagelets[3].priority
  end

  test 'should show id for pagelet' do
    pagelet = ::Pagelets::Pagelet.new("test pagelet", "tests/show", 50, {})
    assert_equal "test pagelet", pagelet.name
    assert_equal "pagelet-id-test_pagelet", pagelet.id
  end

  test 'should override default id' do
    pagelet = ::Pagelets::Pagelet.new("test pagelet", "tests/show", 50, { :id => "custom-id" })
    assert_equal "test pagelet", pagelet.name
    assert_equal "custom-id", pagelet.id
  end
end
