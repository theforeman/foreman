require 'test_helper'

class SafeRenderTest < ActiveSupport::TestCase

  def setup
    @host = FactoryGirl.create(:host)
    @safe_render = SafeRender.new(:variables => { :host => @host })
  end

  test 'safe_render should return raw strings when interpolate is false' do
    Setting[:interpolate_erb_in_parameters] = false

    s=@safe_render.parse('<%= @host.name %>')
    assert_equal '<%= @host.name %>', s
  end

  test 'safe_render should return correct strings when interpolate is true' do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse('<%= @host.name %>')
    assert_equal @host.name, s
  end

  test 'safe_render should return correct arrays when interpolate is true' do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse("['1.2.3.4','<%= @host.name %>']")
    assert_equal "['1.2.3.4','#{@host.name}']", s
  end

  test 'safe_render should return correct hashes when interpolate is true' do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse("{'ip=>'1.2.3.4','name'=>'<%= @host.name %>'}")
    assert_equal "{'ip=>'1.2.3.4','name'=>'#{@host.name}'}", s
  end

  test 'safe_render can handle recursion' do
    Setting[:interpolate_erb_in_parameters] = true

    s=@safe_render.parse("['level1','<%= @host.name %>',['level2','<%= @host.name %>']]")
    assert_equal "['level1','#{@host.name}',['level2','#{@host.name}']]", s
  end

end
