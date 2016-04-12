require 'test_helper'

class RendererTest < ActiveSupport::TestCase
  include Foreman::Renderer

  test "should indent a string" do
    indented = indent 4 do
      "foo\nbar\nbaz"
    end
    assert_equal indented, "    foo\n    bar\n    baz"
  end

  describe "preseed_attributes" do
    test "do not set @preseed_server and @preseed_path if @host does not have medium and os" do
      @host = FactoryGirl.build(:host)
      preseed_attributes
      assert_nil @preseed_path
      assert_nil @preseed_server
    end

    test "set @preseed_server and @preseed_path if @host has medium and os" do
      @host = FactoryGirl.build(:host, :managed)
      architecture = FactoryGirl.build(:architecture)
      medium = FactoryGirl.build(:medium, :path => 'http://my-example.com/my_path')
      os = FactoryGirl.build(:debian7_0, :media => [ medium ])
      @host.architecture = architecture
      @host.operatingsystem = os
      @host.medium = medium
      preseed_attributes
      assert_equal @preseed_path, '/my_path'
      assert_equal @preseed_server, 'my-example.com:80'
    end
  end
end
