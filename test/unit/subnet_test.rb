require 'test_helper'

class SubnetTest < ActiveSupport::TestCase
  def setup
    @subnet = Subnet.new
  end

  test "should have a number" do
    @subnet.mask = "123.123.123.1"
    assert !@subnet.save

    @subnet.number = "192.168.1.1"
    assert @subnet.save
  end

  test "should have a mask" do
    @subnet.number = "123.123.123.1"
    assert !@subnet.save

    @subnet.mask = "192.168.1.1"
    assert @subnet.save
  end

  test "number should have ip format" do
    @subnet.number = "asf.fwe6.we6s.q1"
    @subnet.mask = "123.123.123.1"
    assert !@subnet.save
  end

  test "mask should have ip format" do
    @subnet.mask = "asf.fwe6.we6s.q1"
    @subnet.number = "123.123.123.1"
    assert !@subnet.save
  end

  test "number should be unique" do
    @subnet.number = "123.123.123.1"
    @subnet.mask = "321.321.321.3"
    @subnet.save

    other_subnet = Subnet.create(:name => "123.123.123.1", :mask => "321.321.321.3")
    assert !other_subnet.save
  end
end

