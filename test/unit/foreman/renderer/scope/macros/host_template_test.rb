require 'test_helper'

class HostTemplateTest < ActiveSupport::TestCase
  setup do
    host = FactoryBot.build_stubbed(:host)
    template = OpenStruct.new(
      name: 'Test',
      template: 'Test'
    )
    source = Foreman::Renderer::Source::Database.new(
      template
    )
    @scope = Class.new(Foreman::Renderer::Scope::Base) do
      include Foreman::Renderer::Scope::Macros::HostTemplate
    end.send(:new, host: host, source: source)
  end

  describe '#host_enc' do
    test 'should have host_enc helper' do
      host = FactoryBot.build(:host, :with_puppet)
      @scope.instance_variable_set('@host', host)
      assert @scope.host_enc
    end

    test "should find path in host_enc" do
      host = FactoryBot.build(:host, :with_puppet)
      @scope.instance_variable_set('@host', host)
      assert_equal host.puppetmaster, @scope.host_enc('parameters', 'puppetmaster')
    end

    test "should raise rendering exception if no such parameter exists while rendering host_enc" do
      host = FactoryBot.build(:host, :with_puppet)
      @scope.instance_variable_set('@host', host)
      assert_raises(Foreman::Renderer::Errors::HostENCParamUndefined) do
        assert_equal host.puppetmaster, @scope.host_enc('parameters', 'puppetmaster_that_does_not_exist')
      end
    end

    test 'should raise rendering exception if @host is not set while rendering host_enc' do
      @scope.instance_variable_set('@host', nil)
      assert_raises(Foreman::Renderer::Errors::HostUnknown) do
        @scope.host_enc('parameters', 'puppetmaster')
      end
    end
  end

  describe '#host_param' do
    test 'should render host param using "host_param" helper' do
      host = FactoryBot.build(:host, :with_puppet)
      @scope.instance_variable_set('@host', host)
      assert @scope.host_param('test').present?
    end

    test 'should render host param using "host_param" helper for not existing parameter' do
      host = FactoryBot.build(:host, :with_puppet)
      @scope.instance_variable_set('@host', host)
      assert_nil @scope.host_param('not_existing_param')
    end

    test 'should render host param using "host_param" helper for not existing parameter using default value' do
      host = FactoryBot.build(:host, :with_puppet)
      @scope.instance_variable_set('@host', host)
      assert_equal 42, @scope.host_param('not_existing_param', 42)
    end

    test 'should raise rendering exception if @host is not set while rendering @host based macros' do
      @scope.instance_variable_set('@host', nil)
      assert_raises(Foreman::Renderer::Errors::HostUnknown) do
        @scope.host_param('test')
      end
    end
  end

  describe '#host_param!' do
    test 'should raise rendering exception if host_param! is used for not existing param' do
      host = FactoryBot.build(:host, :with_puppet)
      @scope.instance_variable_set('@host', host)
      assert_raises(Foreman::Renderer::Errors::HostParamUndefined) do
        @scope.host_param!('not_existing_param')
      end
    end
  end

  describe '#host_puppet_server' do
    test 'should render puppet_server' do
      host = stub(puppet_server: 'myserver.example.com')
      @scope.instance_variable_set('@host', host)
      assert_equal @scope.host_puppet_server, 'myserver.example.com'
    end

    test 'should render puppet_server parameter when puppet_server not defined' do
      host = stub()
      @scope.instance_variable_set('@host', host)
      @scope.expects(:host_param).with('puppet_server').returns('myserver.example.com')
      assert_equal @scope.host_puppet_server, 'myserver.example.com'
    end
  end

  describe '#host_puppet_ca_server' do
    test 'should render puppet_ca_server' do
      host = stub(puppet_ca_server: 'myserver.example.com')
      @scope.instance_variable_set('@host', host)
      assert_equal @scope.host_puppet_ca_server, 'myserver.example.com'
    end

    test 'should render puppet_ca_server parameter when puppet_ca_server not defined' do
      host = stub()
      @scope.instance_variable_set('@host', host)
      @scope.expects(:host_param).with('puppet_ca_server').returns('myserver.example.com')
      assert_equal @scope.host_puppet_ca_server, 'myserver.example.com'
    end
  end

  describe '#host_puppet_environment' do
    test 'should render environment' do
      host = stub(environment: 'production')
      @scope.instance_variable_set('@host', host)
      assert_equal @scope.host_puppet_environment, 'production'
    end

    test 'should render puppet_environment parameter when environment not defined' do
      host = stub()
      @scope.instance_variable_set('@host', host)
      @scope.expects(:host_param).with('puppet_environment').returns('production')
      assert_equal @scope.host_puppet_environment, 'production'
    end
  end

  describe '#host_puppet_classes' do
    test 'should render puppetclasses using host_puppetclasses helper' do
      host = FactoryBot.build(:host, :with_puppetclass)
      @scope.instance_variable_set('@host', host)
      assert @scope.host_puppet_classes
    end
  end

  describe '#host_param_true?' do
    test 'should have host_param_true? helper' do
      host = FactoryBot.create(:host, :with_puppet)
      @scope.instance_variable_set('@host', host)
      FactoryBot.create(:parameter, :name => 'true_param', :value => "true")
      assert @scope.host_param_true?('true_param')
      refute @scope.host_param_true?('false_param')
    end
  end

  describe '#host_param_false?' do
    test 'should have host_param_false? helper' do
      host = FactoryBot.create(:host, :with_puppet)
      @scope.instance_variable_set('@host', host)
      FactoryBot.create(:parameter, :name => 'false_param', :value => "false")
      assert @scope.host_param_false?('false_param')
      refute @scope.host_param_false?('true_param')
    end
  end

  describe '#root_pass' do
    test 'should have root_pass helper' do
      host = FactoryBot.create(:host)
      @scope.instance_variable_set('@host', host)
      assert_equal host.root_pass, @scope.root_pass
    end
  end

  describe '#grub_pass' do
    let(:host) { FactoryBot.create(:host) }

    test 'should have grub_pass helper that returns an empty string' do
      @scope.instance_variable_set('@host', host)
      assert_equal '', @scope.grub_pass
    end

    test 'grub_pass helper returns the grub password if enabled' do
      @scope.instance_variable_set('@host', host)
      FactoryBot.create(:parameter, name: 'encrypt_grub', value: 'true')
      assert_equal "--iscrypted --password=#{host.grub_pass}", @scope.grub_pass
    end

    test "grub_pass helper doesn't return the grub password if disabled" do
      @scope.instance_variable_set('@host', host)
      FactoryBot.create(:parameter, name: 'encrypt_grub', value: 'false')
      assert_equal '', @scope.grub_pass
    end
  end

  describe '#ks_console' do
    let(:host) { FactoryBot.create(:host) }

    test 'should have ks_console helper that returns an empty string' do
      @scope.instance_variable_set('@host', host)
      assert_equal '', @scope.ks_console
    end

    test 'should have ks_console helper that returns a console setting' do
      @scope.instance_variable_set('@host', host)
      @scope.instance_variable_set('@port', 0)
      @scope.instance_variable_set('@baud', 9600)
      assert_equal 'console=ttyS0,9600', @scope.ks_console
    end
  end

  describe '#install_packages' do
    test 'no packages' do
      os = FactoryBot.create(:operatingsystem, family: 'Redhat', name: 'CentOS')
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)

      assert_includes '', @scope.install_packages(nil)
    end

    test 'no OS' do
      host = FactoryBot.create(:host, operatingsystem: nil)
      @scope.instance_variable_set('@host', host)

      error = assert_raises(Foreman::Renderer::Errors::UnsupportedOS) do
        @scope.install_packages('pkg1')
      end

      assert_includes error.message, 'Unsupported or no operating system found for this host.'
    end

    test 'unsupported OS' do
      os = FactoryBot.create(:operatingsystem, family: 'AIX')
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)

      error = assert_raises(Foreman::Renderer::Errors::UnsupportedOS) do
        @scope.install_packages('pkg1')
      end

      assert_includes error.message, 'Unsupported or no operating system found for this host.'
    end

    test 'RHEL 7' do
      os = FactoryBot.create(:operatingsystem, family: 'Redhat', name: 'RedHat', major: 7)
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.install_packages('pkg1')

      assert_includes command, 'yum -y install pkg1'
    end

    test 'RHEL 8' do
      os = FactoryBot.create(:operatingsystem, family: 'Redhat', name: 'RedHat', major: 8)
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.install_packages('pkg1')

      assert_includes command, 'dnf -y install pkg1'
    end

    test 'fedora 21' do
      os = FactoryBot.create(:operatingsystem, family: 'Redhat', name: 'Fedora', major: 21)
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.install_packages('pkg1')

      assert_includes command, 'yum -y install pkg1'
    end

    test 'fedora 22' do
      os = FactoryBot.create(:operatingsystem, family: 'Redhat', name: 'Fedora', major: 22)
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.install_packages('pkg1')

      assert_includes command, 'dnf -y install pkg1'
    end

    test 'debian' do
      os = FactoryBot.create(:operatingsystem, family: 'Debian', name: 'Debian', release_name: 'Buster')
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.install_packages('pkg1')

      assert_includes command, 'apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y install pkg1'
    end

    test 'openSUSE' do
      os = FactoryBot.create(:operatingsystem, family: 'Suse', name: 'OpenSUSE')
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.install_packages('pkg1')

      assert_includes command, 'zypper -n install pkg1'
    end
  end

  describe '#update_packages' do
    test 'unsupported OS' do
      os = FactoryBot.create(:operatingsystem, family: 'AIX')
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)

      error = assert_raises(Foreman::Renderer::Errors::UnsupportedOS) do
        @scope.update_packages
      end

      assert_includes error.message, 'Unsupported or no operating system found for this host.'
    end

    test 'RHEL 7' do
      os = FactoryBot.create(:operatingsystem, family: 'Redhat', name: 'RedHat', major: 7)
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.update_packages

      assert_includes command, 'yum -y update'
    end

    test 'RHEL 8' do
      os = FactoryBot.create(:operatingsystem, family: 'Redhat', name: 'RedHat', major: 8)
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.update_packages

      assert_includes command, 'dnf -y update'
    end

    test 'fedora 21' do
      os = FactoryBot.create(:operatingsystem, family: 'Redhat', name: 'Fedora', major: 21)
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.update_packages

      assert_includes command, 'yum -y update'
    end

    test 'fedora 22' do
      os = FactoryBot.create(:operatingsystem, family: 'Redhat', name: 'Fedora', major: 22)
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.update_packages

      assert_includes command, 'dnf -y update'
    end

    test 'debian' do
      os = FactoryBot.create(:operatingsystem, family: 'Debian', name: 'Debian', release_name: 'Buster')
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.update_packages

      assert_includes command, 'apt-get -y update'
      assert_includes command, 'apt-get -y upgrade'
    end

    test 'openSUSE' do
      os = FactoryBot.create(:operatingsystem, family: 'Suse', name: 'OpenSUSE')
      host = FactoryBot.create(:host, operatingsystem: os)
      @scope.instance_variable_set('@host', host)
      command = @scope.update_packages

      assert_includes command, 'zypper -n update'
    end
  end
end
