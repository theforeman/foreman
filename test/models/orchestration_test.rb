require 'test_helper'

class OrchestrationTest < ActiveSupport::TestCase
  module Orchestration::TestModule
    extend ActiveSupport::Concern

    included do
      register_rebuild(:rebuild_test, N_('TEST'))
    end

    def rebuild_test
    end
  end

  module Orchestration::HostTest
    extend ActiveSupport::Concern

    included do
      register_rebuild(:rebuild_host, N_('HOST'))
      register_rebuild(:rebuild_tftp, N_('TFTP'))
    end

    def rebuild_host
    end
  end

  def test_host_should_have_queue
    h = Host.new
    assert_respond_to h, :queue
  end

  setup do
    @host = FactoryBot.create(:host)
    @nic = FactoryBot.create(:nic_managed, :host => @host, :ip => '192.168.0.2')
  end

  test "test host can call protected queue methods" do
    class Host::Test1 < Host::Base
      include Orchestration
      def test_execute(method)
        execute({:action => [self, method]})
      end

      protected

      def setTest
        true
      end
    end
    h = Host::Test1.new
    assert h.test_execute(:setTest)
    assert_raise Foreman::Exception do
      h.test_execute(:noSuchTest)
    end
  end

  class Host::WithDummyAction < Host::Base
    include Orchestration
    after_validation :queue_test

    def queue_test
      queue.create(
        :name => 'dummy action',
        :priority => 1,
        :action => [self, :setAction]
      )
    end

    def setAction
      true
    end
  end

  test "test dummy action host can be created and calls update_cache" do
    uuid = '710d4a8f-b1b6-47f5-9ef5-5892a19dabcd'
    Foreman.stubs(:uuid).returns(uuid)
    h = Host::WithDummyAction.new(:name => "test1")
    h.stubs(:skip_orchestration?).returns(false)
    Rails.cache.expects(:write).with(uuid, any_parameters).at_least_once.returns(true)
    h.save!
  end

  test "test dummy action host compensates queue if active record not saved" do
    h = Host::WithDummyAction.new(:name => 'test1')
    h.stubs(:skip_orchestration?).returns(false)
    h.stubs(:update_cache).returns(true)
    h.stubs(:_create_record).raises(ActiveRecord::InvalidForeignKey, 'Fake foreign key exception')

    # rollback should be called
    h.expects(:delAction).returns(true)

    assert_raise ActiveRecord::InvalidForeignKey do
      h.save!
    end
  end

  test "parameters can be passed to queue methods" do
    class Host::Test < Host::Base
      include Orchestration
      def test_execute(method)
        execute({:action => [self, method, 'abc']})
      end

      protected

      def setTest(param)
        "got #{param}"
      end
    end
    h = Host::Test.new
    h.expects(:setTest).with('abc').returns(true)
    assert h.test_execute(:setTest)
  end

  test "orchestration can clone object with type attribute" do
    @nic.ip = '192.168.0.1'
    @nic.type = 'Nic::Managed'
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
    assert_equal 'aa:aa:aa:aa:aa:aa', clone.mac
    assert_equal '192.168.0.2', clone.ip
  end

  test "orchestration can clone object with belongs_to associations by updating association id" do
    # in rails 2 we had to reload associations, this tests prevents regressions after we dropped it in rails 3
    @host2 = FactoryBot.create(:host)
    @nic.host_id = @host2.id
    clone = @nic.send(:setup_object_clone, @nic)
    refute_equal @nic.object_id, clone.object_id
    assert_equal @host, clone.host
    assert_equal @host2, @nic.host
  end

  context "when registering orchestration rebuild methods" do
    setup do
      @klass = Class.new(ApplicationRecord) do
        include Orchestration
        include Orchestration::TestModule
      end
    end

    test "register_rebuild can register methods" do
      assert @klass.respond_to? :register_rebuild
      assert @klass.ancestors.include? Orchestration::TestModule
    end

    test "we can retrieve registered methods" do
      assert @klass.rebuild_methods.key?(:rebuild_test)
    end

    test "we cannot override already subscribed methods" do
      @klass.send(:include, Orchestration::HostTest)

      module Orchestration::HostTest2
        extend ActiveSupport::Concern

        included do
          register_rebuild(:rebuild_host, N_('HOST'))
        end

        def rebuild_host
        end
      end
      assert_raises(RuntimeError) { @klass.send :include, Orchestration::HostTest2 }
    end
  end

  context "when getting orchestration methods" do
    test "get all from rebuild_methods_for all" do
      assert_equal @host.class.rebuild_methods.values, @host.class.rebuild_methods_for.values
    end

    test "get all from rebuild_methods_for empty" do
      assert_equal @host.class.rebuild_methods.values, @host.class.rebuild_methods_for([]).values
    end

    test "get one from rebuild_methods_for" do
      assert_equal ['TFTP'], @nic.class.rebuild_methods_for(['TFTP']).values
    end
  end

  describe '#attr_equivalent?' do
    test 'two identical strings are equal' do
      assert_equal true, @host.send(:attr_equivalent?, 'test', 'test')
    end

    test 'nil and an empty string are equal' do
      assert_equal true, @host.send(:attr_equivalent?, '', nil)
    end

    test 'two different strings are not equal' do
      assert_equal false, @host.send(:attr_equivalent?, 'test', 'different')
    end

    test 'nil and a string are not equal' do
      assert_equal false, @host.send(:attr_equivalent?, 'test', nil)
    end
  end
end
