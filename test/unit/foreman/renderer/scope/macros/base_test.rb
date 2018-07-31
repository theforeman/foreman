require 'test_helper'

class BaseMacrosTest < ActiveSupport::TestCase
  setup do
    host = FactoryBot.build_stubbed(:host)
    @subject = Class.new(Foreman::Renderer::Scope::Base) do
      include Foreman::Renderer::Scope::Macros::Base
    end.send(:new, host: host)
  end

  describe '#template_name' do
    test 'should returns template name' do
      @subject.instance_variable_set('@template_name', 'asd')
      assert_equal @subject.template_name, 'asd'
    end
  end

  test "should indent a string" do
    indented = @subject.indent 4 do
      "foo\nbar\nbaz"
    end
    assert_equal indented, "    foo\n    bar\n    baz"
  end

  test '#foreman_url can be rendered even outside of controller context' do
    assert_nothing_raised do
      assert_match /\/unattended\/built/, @subject.foreman_url('built')
    end
  end

  test "foreman_url should respect proxy with Templates feature" do
    host = FactoryBot.build(:host, :with_separate_provision_interface, :with_dhcp_orchestration)
    host.provision_interface.subnet.template = FactoryBot.build(:template_smart_proxy)
    ProxyAPI::Template.any_instance.stubs(:template_url).returns(host.provision_interface.subnet.template.url)

    @subject.instance_variable_set('@host', host)

    assert_match(host.provision_interface.subnet.template.url, @subject.foreman_url)
  end

  test "foreman_url should run with @host as nil" do
    @subject.instance_variable_set('@host', nil)

    assert_nothing_raised { @subject.foreman_url }
  end

  test "pxe_kernel_options are not set when no OS is set" do
    host = FactoryBot.build_stubbed(:host)

    @subject.instance_variable_set('@host', host)

    assert_equal '', @subject.pxe_kernel_options
  end

  ["Redhat", "Ubuntu", "OpenSuse", "Solaris"].each do |osname|
    test "pxe_kernel_options returns kernelcmd option for #{osname}" do
      host = FactoryBot.build_stubbed(:host, :operatingsystem => Operatingsystem.find_by_name(osname))
      host.params['kernelcmd'] = 'one two'
      @subject.instance_variable_set('@host', host)
      assert_equal 'one two', @subject.pxe_kernel_options
    end
  end

  test "pxe_kernel_options returns blacklist option for Red Hat" do
    host = FactoryBot.build_stubbed(:host, :operatingsystem => Operatingsystem.find_by_name('Redhat'))
    host.params['blacklist'] = 'dirty_driver, badbad_driver'
    @subject.instance_variable_set('@host', host)
    assert_equal 'modprobe.blacklist=dirty_driver,badbad_driver', @subject.pxe_kernel_options
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

  context 'subnet helpers' do
    setup do
      host = FactoryBot.build(:host, :with_puppet)
      @subject.instance_variable_set('@host', host)
      subnets(:one).subnet_parameters.create(name: 'myparam', value: 'myvalue')
    end

    test 'should have subnet_has_param? helper returning true' do
      assert @subject.subnet_has_param?(subnets(:one), 'myparam')
    end

    test 'should have subnet_has_param? helper returning false' do
      refute @subject.subnet_has_param?(subnets(:one), 'my_wrong_param')
    end

    test 'should have subnet_has_param? helper returning false when subnet is nil' do
      assert_raises Foreman::Renderer::Errors::WrongSubnetError do
        @subject.subnet_has_param?(nil, 'myparam')
      end
    end

    test 'should render existing subnet param using "subnet_param" helper' do
      assert_equal @subject.subnet_param(subnets(:one), 'myparam'), 'myvalue'
    end

    test 'should not render missing subnet param using "subnet_param" helper' do
      assert_nil @subject.subnet_param(subnets(:one), 'my_wrong_param')
    end

    test 'should throw an error using "subnet_param" helper with nil' do
      assert_raises Foreman::Renderer::Errors::WrongSubnetError do
        @subject.subnet_param(nil, 'myparam')
      end
    end
  end
end
