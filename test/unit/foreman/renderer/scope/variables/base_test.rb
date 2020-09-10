require 'test_helper'

class BaseVariablesTest < ActiveSupport::TestCase
  setup do
    template = OpenStruct.new(name: 'Test', template: 'Test')
    @source = Foreman::Renderer::Source::Database.new(template)
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
      host = FactoryBot.build_stubbed(:host, :managed, :debian)
      uri = URI(host.operatingsystem.media.first.path)
      scope = @scope.new(host: host, source: @source)

      assert_equal scope.instance_variable_get('@preseed_path'), uri.path
      assert_equal scope.instance_variable_get('@preseed_server'), uri.select(:host, :port).join(':')
    end

    test "sets @additional_media from medium provider" do
      additional_media = [{name: 'SaltStack', url: 'http://ppa.launchpad.net/saltstack/salt/ubuntu', gpgkey: 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x4759FA960E27C0A6'}]

      host = FactoryBot.build_stubbed(:host, :managed, :debian)
      MediumProviders::Default.any_instance.stubs(:additional_media).returns(additional_media)

      scope = @scope.new(host: host, source: @source)
      assert_equal additional_media.map(&:with_indifferent_access), scope.instance_variable_get('@additional_media')
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
                           "- SLES 12\n" \
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

  describe "kickstart_attributes" do
    test "does not fail if @host does not have medium" do
      host = FactoryBot.build_stubbed(:host)
      scope = @scope.new(host: host, source: @source)
      assert_nil scope.instance_variable_get('@mediapath')
    end

    test "sets @arch" do
      host = FactoryBot.build_stubbed(:host, :managed, :redhat)
      scope = @scope.new(host: host, source: @source)
      assert_equal scope.instance_variable_get('@arch'), host.architecture_name
    end

    test "sets @osver" do
      host = FactoryBot.build_stubbed(:host, :managed, :redhat)
      os = host.operatingsystem
      scope = @scope.new(host: host, source: @source)
      assert_equal scope.instance_variable_get('@osver'), os.major.to_i
    end

    test "sets @mediapath" do
      host = FactoryBot.build_stubbed(:host, :managed, :redhat)
      media = host.operatingsystem.media.first.path
      scope = @scope.new(host: host, source: @source)
      assert_equal scope.instance_variable_get('@mediapath'), "url --url #{media}"
    end

    test "sets @additional_media from medium provider" do
      additional_media = [{name: 'EPEL', url: 'http://yum.example.com/epel'}]

      host = FactoryBot.build_stubbed(:host, :managed, :redhat)
      MediumProviders::Default.any_instance.stubs(:additional_media).returns(additional_media)

      scope = @scope.new(host: host, source: @source)
      assert_equal additional_media.map(&:with_indifferent_access), scope.instance_variable_get('@additional_media')
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
    os = FactoryBot.build_stubbed(:debian7_0, :media => [medium], :architectures => [architecture])
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
