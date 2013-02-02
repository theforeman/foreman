require 'test_helper'

class SafeRenderTest < ActiveSupport::TestCase

  def setup
    @safe_render = SafeRender.new(:variables => { :host => hosts(:one) } )
  end

  test "should evaluate template variables under safemode" do
    Setting.expects(:[]).with(:safemode_render).returns(true)
    tmpl = SafeRender.new(:variables => {:foo => 'bar'}).send(:parse_string, '<%= @foo -%>')
    assert_equal 'bar', tmpl
  end

  test "should evaluate template variables without safemode" do
    Setting.expects(:[]).with(:safemode_render).returns(false)
    tmpl = SafeRender.new(:variables => {:foo => 'bar'}).send(:parse_string, '<%= @foo -%>')
    assert_equal 'bar', tmpl
  end

  test "should evaluate renderer methods under safemode" do
    Setting.expects(:[]).with(:safemode_render).returns(true)
    SafeRender.any_instance.stubs(:foreman_url).returns('bar')
    tmpl = SafeRender.new(:methods => [:foreman_url]).send(:parse_string, '<%= foreman_url -%>')
    assert_equal 'bar', tmpl
  end

  test "should evaluate renderer methods without safemode" do
    Setting.expects(:[]).with(:safemode_render).returns(false)
    SafeRender.any_instance.stubs(:foreman_url).returns('bar')
    tmpl = SafeRender.new(:methods => [:foreman_url]).send(:parse_string, '<%= foreman_url -%>')
    assert_equal 'bar', tmpl
  end

  test "should return raw parameters when interpolate is false" do
    Setting[:interpolate_erb_in_parameters] = false

    s=@safe_render.parse('<%= @host.name %>')
    assert_equal '<%= @host.name %>', s
  end

  test "should return correct parameters when interpolate is true" do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse('<%= @host.name %>')
    assert_equal 'my5name.mydomain.net', s
  end

  test "should return correct arrays when interpolate is true" do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse("['1.2.3.4','<%= @host.name %>']")
    assert_equal "['1.2.3.4','my5name.mydomain.net']", s
  end

  test "should return correct hashes when interpolate is true" do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse("{'ip=>'1.2.3.4','name'=>'<%= @host.name %>'}")
    assert_equal "{'ip=>'1.2.3.4','name'=>'my5name.mydomain.net'}", s
  end

  test "should handle recursion" do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse("['level1','<%= @host.name %>',['level2','<%= @host.name %>']]")
    assert_equal "['level1','my5name.mydomain.net',['level2','my5name.mydomain.net']]", s
  end

end
