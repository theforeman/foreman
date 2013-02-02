require 'test_helper'

class SafeRenderTest < ActiveSupport::TestCase

  def setup
    @saferender = SafeRender.new(:variables => { :host => hosts(:one) } )
  end

  test "safe_render should return raw strings when interpolate is false" do
    Setting[:interpolate_erb_in_parameters] = false

    s=@saferender.parse('<%= @host.name %>')
    assert_equal '<%= @host.name %>', s
  end

  test "safe_render should return correct strings when interpolate is true" do
    Setting[:interpolate_erb_in_parameters] = true

    s=@saferender.parse('<%= @host.name %>')
    assert_equal 'my5name.mydomain.net', s
  end

  test "safe_render should return correct arrays when interpolate is true" do
    Setting[:interpolate_erb_in_parameters] = true

    s=@saferender.parse("['1.2.3.4','<%= @host.name %>']")
    assert_equal "['1.2.3.4','my5name.mydomain.net']", s
  end

  test "safe_render should return correct hashes when interpolate is true" do
    Setting[:interpolate_erb_in_parameters] = true

    s=@saferender.parse("{'ip=>'1.2.3.4','name'=>'<%= @host.name %>'}")
    assert_equal "{'ip=>'1.2.3.4','name'=>'my5name.mydomain.net'}", s
  end

  test "safe_render can handle recursion" do
    Setting[:interpolate_erb_in_parameters] = true

    s=@saferender.parse("['level1','<%= @host.name %>',['level2','<%= @host.name %>']]")
    assert_equal "['level1','my5name.mydomain.net',['level2','my5name.mydomain.net']]", s
  end

end
