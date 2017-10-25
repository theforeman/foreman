require "test_helper"

class NicDnsInterfaceTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  context "#dns_record" do
    setup do
      @nic = FactoryGirl.build(:nic_managed)
      @feasible_methods = {
        a: :dns?,
        aaaa: :dns6?,
        ptr4: :reverse_dns?,
        ptr6: :reverse_dns6?,
        cname: :dns?,
      }
    end

    test "should raise error on invalid type" do
      assert_raises Foreman::Exception do
        @nic.dns_record(:invalid)
      end
    end

    DnsInterface::RECORD_TYPES.each do |type|
      test "should return stored dns_record #{type}" do
        record = stub()
        @nic.instance_variable_set("@dns_#{type}_record", record)
        assert_equal record, @nic.dns_record(type)
      end

      test "should return and store dns_record" do
        stub = stub()

        klass = "Net::DNS::#{type.upcase}Record".constantize
        klass.expects(:new).with({}).once.returns(stub)

        @nic.expects(@feasible_methods[type]).returns(true)

        @nic.expects("dns_#{type}_record_attrs".to_sym).once.returns({})
        record = @nic.dns_record(type)
        assert_equal stub, record
        assert_equal record, @nic.instance_variable_get("@dns_#{type}_record")
      end

      test "should return nil if #{type} record is not feasible" do
        @nic.expects(@feasible_methods[type]).returns(false)
        assert_nil @nic.dns_record(type)
      end
    end

    test "should return nil if CNAME is not feasible" do
      @nic.expects(:dns?).once.returns(false)
      @nic.expects(:dns6?).once.returns(false)
      assert_nil @nic.dns_record(:cname)
    end
  end
end
