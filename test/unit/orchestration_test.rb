require 'test_helper'

class OrchestrationTest < ActiveSupport::TestCase
  def test_host_should_have_queue
    h = Host.new
    assert_respond_to h, :queue
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
    host = FactoryGirl.create(:host)
    nic = FactoryGirl.create(:nic_managed, :host => host, :ip => '192.168.0.2')
    nic.ip = '192.168.0.1'
    nic.type = 'Nic::Bootable'
    clone = nic.send :setup_object_clone, nic
    refute_equal nic.object_id, clone.object_id
    refute_equal nic.updated_at, clone.updated_at
    assert_equal '192.168.0.2', clone.ip
    assert_equal 'Nic::Managed', clone.type
  end

  test "orchestration can clone object and execute block if given before old attributes are assigned" do
    host = FactoryGirl.create(:host)
    nic = FactoryGirl.create(:nic_managed, :host => host, :ip => '192.168.0.2')
    nic.ip = '192.168.0.1'
    clone = nic.send(:setup_object_clone, nic) { |clone| clone.mac = 'AA:AA:AA:AA:AA:AA'; clone.ip = 'override this' }
    refute_equal nic.object_id, clone.object_id
    assert_equal 'AA:AA:AA:AA:AA:AA', clone.mac
    assert_equal '192.168.0.2', clone.ip
  end

  test "orchestration can clone object with belongs_to associations by updating association id" do
    # in rails 2 we had to reload associations, this tests prevents regressions after we dropped it in rails 3
    host1 = FactoryGirl.create(:host)
    host2 = FactoryGirl.create(:host)
    nic = FactoryGirl.create(:nic_managed, :host => host1)
    nic.host_id = host2.id
    clone = nic.send(:setup_object_clone, nic)
    refute_equal nic.object_id, clone.object_id
    assert_equal host1, clone.host
    assert_equal host2, nic.host
  end

end
