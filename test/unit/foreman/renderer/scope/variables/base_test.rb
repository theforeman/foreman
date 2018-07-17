require 'test_helper'

class BaseVariablesTest < ActiveSupport::TestCase
  setup do
    @subject = Class.new(Foreman::Renderer::Scope::Base) do
      include Foreman::Renderer::Scope::Variables::Base
    end
  end

  describe "preseed_attributes" do
    test "do not set @preseed_server and @preseed_path if @host does not have medium and os" do
      host = FactoryBot.build_stubbed(:host)

      scope = @subject.new(host: host)

      assert_nil scope.instance_variable_get('@preseed_path')
      assert_nil scope.instance_variable_get('@preseed_server')
    end

    test "set @preseed_server and @preseed_path if @host has medium and os" do
      host = FactoryBot.build_stubbed(:host, :managed)
      architecture = FactoryBot.build_stubbed(:architecture)
      medium = FactoryBot.build_stubbed(:medium, :path => 'http://my-example.com/my_path')
      os = FactoryBot.build_stubbed(:debian7_0, :media => [ medium ], :architectures => [architecture])
      host.architecture = architecture
      host.operatingsystem = os
      host.medium = medium

      scope = @subject.new(host: host)

      assert_equal scope.instance_variable_get('@preseed_path'), '/my_path'
      assert_equal scope.instance_variable_get('@preseed_server'), 'my-example.com:80'
    end
  end

  describe "yast_attributes" do
    test "does not fail if @host does not have medium" do
      host = FactoryBot.build_stubbed(:host)

      scope = @subject.new(host: host)

      assert_nil scope.instance_variable_get('@mediapath')
    end
  end

  test "set @initrd and @kernel" do
    host = FactoryBot.build_stubbed(:host, :managed)
    architecture = FactoryBot.build_stubbed(:architecture)
    medium = FactoryBot.build_stubbed(:medium, :path => 'http://my-example.com/my_path')
    os = FactoryBot.build_stubbed(:debian7_0, :media => [ medium ], :architectures => [architecture])
    host.architecture = architecture
    host.operatingsystem = os
    host.medium = medium

    scope = @subject.new(host: host)

    assert scope.instance_variable_get('@initrd').present?
    assert scope.instance_variable_get('@kernel').present?
  end
end
