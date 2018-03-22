require 'test_helper'

class NicDnsInterfaceTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  context '#dns_record' do
    setup do
      @nic = FactoryBot.build_stubbed(:nic_managed)
    end

    test 'should raise error on invalid type' do
      assert_raises Foreman::Exception do
        @nic.dns_record(:invalid)
      end
    end

    test 'should return stored dns_record' do
      record = stub()
      @nic.instance_variable_set('@dns_a_record', record)
      assert_equal record, @nic.dns_record(:a)
    end

    test 'should return nil if dns is not feasible' do
      @nic.expects(:dns?).once.returns(false)
      assert_nil @nic.dns_record(:a)
    end

    test 'should return and store dns_record' do
      stub = stub()
      Net::DNS::ARecord.expects(:new).with({}).once.returns(stub)
      @nic.expects(:dns?).once.returns(true)
      @nic.expects(:dns_a_record_attrs).once.returns({})
      record = @nic.dns_record(:a)
      assert_equal stub, record
      assert_equal record, @nic.instance_variable_get('@dns_a_record')
    end
  end
end
