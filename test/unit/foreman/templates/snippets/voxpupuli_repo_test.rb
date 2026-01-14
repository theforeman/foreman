require 'test_helper'

class VoxPupuliRepoTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_template(host)
    snippet_path = Rails.root.join('app', 'views', 'unattended', 'provisioning_templates', 'snippet', 'voxpupuli_repo.erb')
    @snippet ||= File.read(snippet_path)

    source = OpenStruct.new(
      name: 'Test',
      content: @snippet
    )

    scope = Class.new(Foreman::Renderer::Scope::Provisioning).send(
      :new,
      host: host,
      source: source,
      variables: {
        host: host,
      })

    renderer.render(source, scope)
  end

  # ---------------------------------- DEBIAN ---------------------------------- #
  context 'Debian 13' do
    setup do
      os = FactoryBot.create(:debian13_0, :with_provision, :with_associations)
      @host = FactoryBot.create(:host, :managed, build: true, operatingsystem: os)
    end

    test 'enable-openvox9-repo' do
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)
      output = render_template(@host)

      assert_includes output, 'wget -O /tmp/openvox9-release-debian13.deb https://apt.voxpupuli.org/openvox9-release-debian13.deb'
      assert_includes output, 'dpkg -i /tmp/openvox9-release-debian13.deb'
      assert_no_match(/openvox8/, output)
    end

    test 'enable-openvox8-repo' do
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox8-repo', value: true)
      output = render_template(@host)

      assert_includes output, 'wget -O /tmp/openvox8-release-debian13.deb https://apt.voxpupuli.org/openvox8-release-debian13.deb'
      assert_includes output, 'dpkg -i /tmp/openvox8-release-debian13.deb'
      assert_no_match(/openvox9/, output)
    end

    test 'enable-openvox9-repo and enable-openvox8-repo are mutually exclusive' do
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox8-repo', value: true)

      error = assert_raises(RuntimeError) do
        render_template(@host)
      end

      assert_equal "Both 'enable-openvox9-repo' and 'enable-openvox8-repo' are true", error.message
    end
  end

  # ------------------------------------ EL9 ----------------------------------- #
  [:rhel9, :for_snapshots_rocky9].each do |el9_factory|
    context el9_factory.to_s do
      setup do
        os = FactoryBot.create(el9_factory, :with_provision, :with_associations)
        @host = FactoryBot.create(:host, :managed, build: true, operatingsystem: os)
      end

      test 'enable-openvox9-repo' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)
        output = render_template(@host)

        assert_includes output, 'rpm -Uvh https://yum.voxpupuli.org/openvox9-release-el-9.noarch.rpm'
        assert_no_match(/openvox8/, output)
      end

      test 'enable-openvox8-repo' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox8-repo', value: true)
        output = render_template(@host)

        assert_includes output, 'rpm -Uvh https://yum.voxpupuli.org/openvox8-release-el-9.noarch.rpm'
        assert_no_match(/openvox9/, output)
      end

      test 'enable-openvox8-repo and enable-openvox9-repo are mutually exclusive' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox8-repo', value: true)
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)

        assert_raises(RuntimeError) do
          render_template(@host)
        end
      end
    end
  end

  # ----------------------------------- EL10 ----------------------------------- #
  [:rhel10, :for_snapshots_rocky10].each do |el10_factory|
    context el10_factory.to_s do
      setup do
        os = FactoryBot.create(el10_factory, :with_provision, :with_associations)
        @host = FactoryBot.create(:host, :managed, build: true, operatingsystem: os)
      end

      test 'enable-openvox9-repo' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)
        output = render_template(@host)

        assert_includes output, 'rpm -Uvh https://yum.voxpupuli.org/openvox9-release-el-10.noarch.rpm'
        assert_no_match(/openvox8/, output)
      end

      test 'enable-openvox8-repo' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox8-repo', value: true)
        output = render_template(@host)

        assert_includes output, 'rpm -Uvh https://yum.voxpupuli.org/openvox8-release-el-10.noarch.rpm'
        assert_no_match(/openvox9/, output)
      end

      test 'enable-openvox8-repo and enable-openvox9-repo are mutually exclusive' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox8-repo', value: true)
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)

        assert_raises(RuntimeError) do
          render_template(@host)
        end
      end
    end
  end

  # --------------------------------- OPENSUSE --------------------------------- #
  context 'openSUSE Leap 16.0' do
    setup do
      os = FactoryBot.create(:opensuse_16_0, :with_provision, :with_associations)
      @host = FactoryBot.create(:host, :managed, build: true, operatingsystem: os)
    end

    test 'enable-openvox9-repo' do
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)
      output = render_template(@host)

      assert_includes output, 'rpm -Uvh https://yum.voxpupuli.org/openvox9-release-sles-16.noarch.rpm'
      assert_no_match(/openvox8/, output)
    end

    test 'enable-openvox8-repo' do
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox8-repo', value: true)
      output = render_template(@host)

      assert_includes output, 'rpm -Uvh https://yum.voxpupuli.org/openvox8-release-sles-16.noarch.rpm'
      assert_no_match(/openvox9/, output)
    end

    test 'enable-openvox8-repo and enable-openvox9-repo are mutually exclusive' do
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox8-repo', value: true)
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)

      assert_raises(RuntimeError) do
        render_template(@host)
      end
    end
  end

  # ---------------------------------- UBUNTU ---------------------------------- #
  [:ubuntu22_04, :ubuntu22_04_3].each do |ubuntu_22_factory|
    context ubuntu_22_factory.to_s do
      setup do
        os = FactoryBot.create(ubuntu_22_factory, :with_provision, :with_associations)
        @host = FactoryBot.create(:host, :managed, build: true, operatingsystem: os)
      end

      test 'enable-openvox9-repo' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)
        output = render_template(@host)

        assert_includes output, 'wget -O /tmp/openvox9-release-ubuntu22.04.deb https://apt.voxpupuli.org/openvox9-release-ubuntu22.04.deb'
        assert_includes output, 'dpkg -i /tmp/openvox9-release-ubuntu22.04.deb'
        assert_no_match(/openvox8/, output)
      end

      test 'enable-openvox8-repo' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox8-repo', value: true)
        output = render_template(@host)

        assert_includes output, 'wget -O /tmp/openvox8-release-ubuntu22.04.deb https://apt.voxpupuli.org/openvox8-release-ubuntu22.04.deb'
        assert_includes output, 'dpkg -i /tmp/openvox8-release-ubuntu22.04.deb'
        assert_no_match(/openvox9/, output)
      end

      test 'enable-openvox8-repo and enable-openvox9-repo are mutually exclusive' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox8-repo', value: true)
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)

        assert_raises(RuntimeError) do
          render_template(@host)
        end
      end
    end
  end
end
