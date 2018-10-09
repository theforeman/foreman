require 'test_helper'

class BaseVariablesTest < ActiveSupport::TestCase
  setup do
    template = OpenStruct.new(
      name: 'Test',
      template: 'Test'
    )
    @source = Foreman::Renderer::Source::Database.new(
      template
    )
    @scope = Class.new(Foreman::Renderer::Scope::Base) do
      include Foreman::Renderer::Scope::Variables::Base
    end
  end

  describe "preseed_attributes" do
    test "do not set @preseed_server and @preseed_path if @host does not have medium and os" do
      host = FactoryBot.build_stubbed(:host)

      scope = @scope.new(host: host, source: @source)

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

      scope = @scope.new(host: host, source: @source)

      assert_equal scope.instance_variable_get('@preseed_path'), '/my_path'
      assert_equal scope.instance_variable_get('@preseed_server'), 'my-example.com:80'
    end
  end

  describe "yast_attributes" do
    test "does not fail if @host does not have medium" do
      host = FactoryBot.build_stubbed(:host)

      scope = @scope.new(host: host, source: @source)

      assert_nil scope.instance_variable_get('@mediapath')
    end

    describe "@dynamic" do
      before do
        @ptable_template = "%#\n" \
                           "kind: ptable\n" \
                           "name: test template\n" \
                           "oses:\n" \
                           "- RedHat 7\n" \
                           "%>\n" \
                           "#Dynamic\n"

        ptable = FactoryBot.create(:ptable, template: @ptable_template, operatingsystem_ids: [operatingsystems(:redhat).id])
        @host = FactoryBot.create(:host, :managed, ptable: ptable, operatingsystem: operatingsystems(:redhat))
      end

      test "is true when '#dynamic' is present in the template" do
        scope = @scope.new(host: @host, source: @source)

        assert_equal true, scope.instance_variable_get('@dynamic')
      end

      test "is false when '#dynamic' is not present in the template" do
        @host.ptable.update(template: @ptable_template.gsub('#Dynamic', ''))
        scope = @scope.new(host: @host, source: @source)

        assert_equal false, scope.instance_variable_get('@dynamic')
      end
    end
  end

  test "set kernel and init RAM disk variables" do
    host = FactoryBot.build_stubbed(:host, :managed)
    architecture = FactoryBot.build_stubbed(:architecture)
    medium = FactoryBot.build_stubbed(:medium, :path => 'http://my-example.com/my_path')
    os = FactoryBot.build_stubbed(:debian7_0, :media => [ medium ], :architectures => [architecture])
    host.architecture = architecture
    host.operatingsystem = os
    host.medium = medium

    scope = @scope.new(host: host, source: @source)

    assert scope.instance_variable_get('@kernel').present?
    assert scope.instance_variable_get('@initrd').present?
    assert scope.instance_variable_get('@kernel_uri').present?
    assert scope.instance_variable_get('@initrd_uri').present?
  end

  test "set @provisioning_type for bare host" do
    class Host::BareHost < ::Host::Base; end
    host = Host::BareHost.new
    scope = @scope.new(host: host, source: @source)
    assert_equal "host", scope.instance_variable_get('@provisioning_type')
  end
end
