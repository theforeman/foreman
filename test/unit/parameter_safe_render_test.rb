require 'test_helper'

class ParameterSafeRenderTest < ActiveSupport::TestCase
  def setup
    @host = FactoryBot.build(:host)
    @safe_render = ParameterSafeRender.new(@host)
  end

  test 'safe_render should return empty string' do
    Setting[:interpolate_erb_in_parameters] = true

    s = @safe_render.render('')
    assert_equal '', s
  end

  test 'safe_render should return long string' do
    Setting[:interpolate_erb_in_parameters] = true

    s = @safe_render.render('X' * 1024)
    assert_equal 'X' * 1024, s
  end

  test 'safe_render should return raw strings when interpolate is false' do
    Setting[:interpolate_erb_in_parameters] = false

    s = @safe_render.render('<%= @host.name %>')
    assert_equal '<%= @host.name %>', s
  end

  test 'safe_render should return correct strings when interpolate is true' do
    Setting[:interpolate_erb_in_parameters] = true

    s = @safe_render.render('<%= @host.name %>')
    assert_equal @host.name, s
  end

  test 'safe_render should return correct arrays when interpolate is true' do
    Setting[:interpolate_erb_in_parameters] = true

    s = @safe_render.render("['1.2.3.4','<%= @host.name %>']")
    assert_equal "['1.2.3.4','#{@host.name}']", s
  end

  test 'safe_render should return correct hashes when interpolate is true' do
    Setting[:interpolate_erb_in_parameters] = true

    s = @safe_render.render("{'ip=>'1.2.3.4','name'=>'<%= @host.name %>'}")
    assert_equal "{'ip=>'1.2.3.4','name'=>'#{@host.name}'}", s
  end

  test 'safe_render can handle recursion' do
    Setting[:interpolate_erb_in_parameters] = true

    s = @safe_render.render("['level1','<%= @host.name %>',['level2','<%= @host.name %>']]")
    assert_equal "['level1','#{@host.name}',['level2','#{@host.name}']]", s
  end
end
