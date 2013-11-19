require 'test_helper'

class SafeRenderTest < ActiveSupport::TestCase

  def setup
    @safe_render = SafeRender.new(:variables => { :system => systems(:one) })
  end

  test 'safe_render should return raw strings when interpolate is false' do
    Setting[:interpolate_erb_in_parameters] = false

    s=@safe_render.parse('<%= @system.name %>')
    assert_equal '<%= @system.name %>', s
  end

  test 'safe_render should return correct strings when interpolate is true' do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse('<%= @system.name %>')
    assert_equal 'my5name.mydomain.net', s
  end

  test 'safe_render should return correct arrays when interpolate is true' do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse("['1.2.3.4','<%= @system.name %>']")
    assert_equal "['1.2.3.4','my5name.mydomain.net']", s
  end

  test 'safe_render should return correct hashes when interpolate is true' do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse("{'ip=>'1.2.3.4','name'=>'<%= @system.name %>'}")
    assert_equal "{'ip=>'1.2.3.4','name'=>'my5name.mydomain.net'}", s
  end

  test 'safe_render can handle recursion' do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse("['level1','<%= @system.name %>',['level2','<%= @system.name %>']]")
    assert_equal "['level1','my5name.mydomain.net',['level2','my5name.mydomain.net']]", s
  end

end
