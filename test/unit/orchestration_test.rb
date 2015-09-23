require 'test_helper'

class OrchestrationTest < ActiveSupport::TestCase
  module Orchestration::HostTest
    extend ActiveSupport::Concern

    included do
      register_rebuild(:rebuild_host, N_('HOST'))
    end

    def rebuild_host
    end
  end

  module Orchestration::TestModule
    extend ActiveSupport::Concern

    included do
      register_rebuild(:rebuild_test, N_('TEST'))
    end

    def rebuild_test
    end
  end

  def test_host_should_have_queue
    h = Host.new
    assert_respond_to h, :queue
  end

  setup do
    @host = FactoryGirl.create(:host)
    @nic = FactoryGirl.create(:nic_managed, :host => @host, :ip => '192.168.0.2')
  end

  test "test host can call protected queue methods" do
    class Host::Test < Host::Base
      include Orchestration
      def test_execute(method)
        execute({:action => [self, method]})
      end

      protected

      def setTest; true; end
    end
    h = Host::Test.new
    assert h.test_execute(:setTest)
    assert_raise Foreman::Exception do
      h.test_execute(:noSuchTest)
    end
  end

  test "orchestration can clone object with type attribute" do
    @nic.ip = '192.168.0.1'
    @nic.type = 'Nic::Bootable'
    clone = @nic.send :setup_object_clone, @nic
    refute_equal @nic.object_id, clone.object_id
    refute_equal @nic.updated_at, clone.updated_at
    assert_equal '192.168.0.2', clone.ip
    assert_equal 'Nic::Managed', clone.type
  end

  test "orchestration can clone object and execute block if given before old attributes are assigned" do
    @nic.ip = '192.168.0.1'
    clone = @nic.send(:setup_object_clone, @nic) { |c| c.mac, c.ip = 'AA:AA:AA:AA:AA:AA', 'override this' }
    refute_equal @nic.object_id, clone.object_id
    assert_equal 'AA:AA:AA:AA:AA:AA', clone.mac
    assert_equal '192.168.0.2', clone.ip
  end

  test "orchestration can clone object with belongs_to associations by updating association id" do
    # in rails 2 we had to reload associations, this tests prevents regressions after we dropped it in rails 3
    @host2 = FactoryGirl.create(:host)
    @nic.host_id = @host2.id
    clone = @nic.send(:setup_object_clone, @nic)
    refute_equal @nic.object_id, clone.object_id
    assert_equal @host, clone.host
    assert_equal @host2, @nic.host
  end

  test '#valid? does not trigger cloning in !unattended mode' do
    original, SETTINGS[:unattended] = SETTINGS[:unattended], false
    @nic.expects(:setup_clone).never
    @nic.valid?
    SETTINGS[:unattended] = original
  end

  context "when subscribing orchestration methods to nic" do
    before do
      @nic.class.send(:include, Orchestration::TestModule) unless @nic.is_a?(Orchestration::TestModule)
    end

    test "register_rebuild can register methods" do
      assert @nic.class.respond_to? :register_rebuild
      assert @nic.class.ancestors.include? Orchestration::TestModule
    end

    test "we can retrieve registered methods" do
      assert @nic.class.rebuild_methods.keys.include? :rebuild_test
    end
  end

  context "when subscribing orchestration methods to host" do
    before do
      @host.class.send(:include, Orchestration::HostTest) unless @host.is_a?(Orchestration::HostTest)
    end

    test "register_rebuild can register methods" do
      assert @host.class.respond_to? :register_rebuild
      assert @host.class.ancestors.include? Orchestration::HostTest
    end

    test "we can retrieve registered methods" do
      assert @host.class.rebuild_methods.keys.include? :rebuild_host
    end

    test "we cannot override already subscribed methods" do
      module Orchestration::HostTest2
        extend ActiveSupport::Concern

        included do
          register_rebuild(:rebuild_host, N_('HOST'))
        end

        def rebuild_host
        end
      end
      assert_raises(RuntimeError) { @host.class.send :include, Orchestration::HostTest2 }
    end
  end
end
