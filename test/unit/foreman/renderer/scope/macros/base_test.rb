require 'test_helper'

class BaseMacrosTest < ActiveSupport::TestCase
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
      include Foreman::Renderer::Scope::Macros::Base
    end.send(:new, host: host, source: source)
  end

  describe '#template_name' do
    test 'should returns template name' do
      @scope.instance_variable_set('@template_name', 'asd')
      assert_equal @scope.template_name, 'asd'
    end
  end

  test "should indent a string" do
    indented = @scope.indent 4 do
      "foo\nbar\nbaz"
    end
    assert_equal indented, "    foo\n    bar\n    baz"
  end

  test "should indent a string ignoring the first line" do
    indented = @scope.indent(4, skip1: true) do
      "foo\nbar\nbaz"
    end
    assert_equal indented, "foo\n    bar\n    baz"
  end

  test '#foreman_url can be rendered even outside of controller context' do
    assert_nothing_raised do
      assert_match /\/unattended\/built/, @scope.foreman_url('built')
    end
  end

  test "foreman_url should respect proxy with Templates feature" do
    host = FactoryBot.build(:host, :with_separate_provision_interface, :with_dhcp_orchestration)
    host.provision_interface.subnet.template = FactoryBot.build(:template_smart_proxy)
    ProxyAPI::Template.any_instance.stubs(:template_url).returns(host.provision_interface.subnet.template.url)

    @scope.instance_variable_set('@host', host)

    assert_match(host.provision_interface.subnet.template.url, @scope.foreman_url('provision'))
  end

  test "foreman_url should run with @host as nil" do
    @scope.instance_variable_set('@host', nil)

    assert_nothing_raised { @scope.foreman_url('provision') }
  end

  test "pxe_kernel_options are not set when no OS is set" do
    host = FactoryBot.build_stubbed(:host)

    @scope.instance_variable_set('@host', host)

    assert_equal '', @scope.pxe_kernel_options
  end

  describe '#host_uptime_seconds' do
    test 'should return host uptime in seconds' do
      host = FactoryBot.create(:host)
      facet = host.build_reported_data
      freeze_time do
        facet.update!(:boot_time => 123.seconds.ago)
        assert_equal 123, @scope.host_uptime_seconds(host)
      end
    end
  end

  describe '#host_kernel_release' do
    test 'should return kernel release' do
      host = FactoryBot.create(:host)
      fact = FactoryBot.create(:fact_name, name: 'kernelrelease')
      FactoryBot.create(:fact_value, fact_name: fact, host: host, value: '1.2.3')
      assert_equal '1.2.3', @scope.host_kernel_release(host)
    end

    test 'should return nil if no kernel release fact is available' do
      host = FactoryBot.create(:host)
      assert_nil @scope.host_kernel_release(host)
    end

    test 'should return kernel release and based on backup facts even if there are multiple other facts' do
      host = FactoryBot.create(:host)
      rhsm_host = FactoryBot.create(:host)
      ansible_kernel_fact = FactoryBot.create(:fact_name, name: 'ansible_kernel', type: 'FactName::Ansible')
      chef_kernel_fact = FactoryBot.create(:fact_name, name: 'kernel::release', type: 'FactName::Chef')
      unrelated_fact = FactoryBot.create(:fact_name, name: 'os')
      puppet_and_salt_fact = FactoryBot.create(:fact_name, name: 'kernelrelease')
      rhsm_fact = FactoryBot.create(:fact_name, name: 'uname::release', type: 'FactName::Rhsm')
      FactoryBot.create(:fact_value, fact_name: ansible_kernel_fact, host: host, value: '1.2.3')
      FactoryBot.create(:fact_value, fact_name: chef_kernel_fact, host: host, value: '2.2.2')
      FactoryBot.create(:fact_value, fact_name: unrelated_fact, host: host, value: 'Fedora 29')
      assert_equal '1.2.3', @scope.host_kernel_release(host)
      FactoryBot.create(:fact_value, fact_name: puppet_and_salt_fact, host: host, value: '4.5.6')
      assert_equal '4.5.6', @scope.host_kernel_release(host.reload)
      FactoryBot.create(:fact_value, fact_name: rhsm_fact, host: rhsm_host, value: '7.8.9')
      assert_equal '7.8.9', @scope.host_kernel_release(rhsm_host)
    end
  end

  ["Redhat", "Ubuntu", "OpenSuse", "Solaris"].each do |osname|
    test "pxe_kernel_options returns kernelcmd option for #{osname}" do
      host = FactoryBot.build_stubbed(:host, :operatingsystem => Operatingsystem.find_by_name(osname))
      host.params['kernelcmd'] = 'one two'
      @scope.instance_variable_set('@host', host)
      assert_equal 'one two', @scope.pxe_kernel_options
    end
  end

  test "pxe_kernel_options returns blacklist option for Red Hat" do
    host = FactoryBot.build_stubbed(:host, :operatingsystem => Operatingsystem.find_by_name('Redhat'))
    host.params['blacklist'] = 'dirty_driver, badbad_driver'
    @scope.instance_variable_set('@host', host)
    assert_equal 'modprobe.blacklist=dirty_driver,badbad_driver', @scope.pxe_kernel_options
  end

  test 'ActiveRecord::AssociationRelation jail test' do
    allowed = [:[], :each, :first, :to_a, :find_in_batches]
    allowed.each do |m|
      assert ActiveRecord::AssociationRelation::Jail.allowed?(m), "Method #{m} is not available in ActiveRecord::AssociationRelation::Jail while should be allowed."
    end
  end

  test 'ActiveRecord::Associations::CollectionProxy jail test' do
    allowed = [:[], :each, :first, :to_a, :find_in_batches]
    allowed.each do |m|
      assert ActiveRecord::AssociationRelation::Jail.allowed?(m), "Method #{m} is not available in ActiveRecord::Associations::CollectionProxy::Jail while should be allowed."
    end
  end

  test 'URI::Generic jail test' do
    allowed = [:host, :path, :port, :query, :scheme]
    allowed.each do |m|
      assert URI::HTTP::Jail.allowed?(m), "Method #{m} is not available in URI::HTTP::Jail while should be allowed."
    end
  end

  context 'subnet helpers' do
    setup do
      host = FactoryBot.build(:host)
      @scope.instance_variable_set('@host', host)
      subnets(:one).subnet_parameters.create(name: 'myparam', value: 'myvalue')
    end

    test 'should have subnet_has_param? helper returning true' do
      assert @scope.subnet_has_param?(subnets(:one), 'myparam')
    end

    test 'should have subnet_has_param? helper returning false' do
      refute @scope.subnet_has_param?(subnets(:one), 'my_wrong_param')
    end

    test 'should have subnet_has_param? helper returning false when subnet is nil' do
      assert_raises Foreman::Renderer::Errors::WrongSubnetError do
        @scope.subnet_has_param?(nil, 'myparam')
      end
    end

    test 'should render existing subnet param using "subnet_param" helper' do
      assert_equal @scope.subnet_param(subnets(:one), 'myparam'), 'myvalue'
    end

    test 'should not render missing subnet param using "subnet_param" helper' do
      assert_nil @scope.subnet_param(subnets(:one), 'my_wrong_param')
    end

    test 'should throw an error using "subnet_param" helper with nil' do
      assert_raises Foreman::Renderer::Errors::WrongSubnetError do
        @scope.subnet_param(nil, 'myparam')
      end
    end
  end
end
