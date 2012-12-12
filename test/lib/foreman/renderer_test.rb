require 'test_helper'
require 'foreman/renderer'

class RendererTest < ActiveSupport::TestCase
  include Foreman::Renderer

  test "should evaluate template variables under safemode" do
    Setting.expects(:[]).with(:safemode_render).returns(true)
    tmpl = render_safe('<%= @foo -%>', [], { :foo => 'bar' })
    assert_equal 'bar', tmpl
  end

  test "should evaluate template variables without safemode" do
    Setting.expects(:[]).with(:safemode_render).returns(false)
    tmpl = render_safe('<%= @foo -%>', [], { :foo => 'bar' })
    assert_equal 'bar', tmpl
  end

  test "should evaluate renderer methods under safemode" do
    Setting.expects(:[]).with(:safemode_render).returns(true)
    self.expects(:foreman_url).returns('bar')
    tmpl = render_safe('<%= foreman_url -%>', [:foreman_url])
    assert_equal 'bar', tmpl
  end

  test "should evaluate renderer methods without safemode" do
    Setting.expects(:[]).with(:safemode_render).returns(false)
    self.expects(:foreman_url).returns('bar')
    tmpl = render_safe('<%= foreman_url -%>')
    assert_equal 'bar', tmpl
  end
end
