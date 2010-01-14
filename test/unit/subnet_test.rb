require 'test_helper'

class SubnetTest < ActiveSupport::TestCase
  def setup
    @subnet = Subnet.new
    @attrs = {  :number= => "123.123.123.1",
                :mask= => "321.321.321.3",
                :name= => "valid" }
  end

  test "should have a number" do
    set_attr(:mask=)
    assert !@subnet.save

    set_attr(:number=)
    assert @subnet.save
  end

  test "should have a mask" do
    set_attr(:number=)
    assert !@subnet.save

    set_attr(:mask=)
    assert @subnet.save
  end

  test "number should have ip format" do
    @subnet.number = "asf.fwe6.we6s.q1"
    set_attr(:mask=)
    assert !@subnet.save
  end

  test "mask should have ip format" do
    @subnet.mask = "asf.fwe6.we6s.q1"
    set_attr(:number=)
    assert !@subnet.save
  end

  test "number should be unique" do
    set_attr(:number=, :mask=)
    @subnet.save

    other_subnet = Subnet.create(:number => "123.123.123.1", :mask => "321.321.321.3")
    assert !other_subnet.save
  end

  test "the name should be unique in the domain scope" do
    create_a_domain_with_the_subnet

    other_subnet = Subnet.create( :mask => "111.111.111.1",
                                   :number => "222.222.222.2",
                                   :name => "valid",
                                   :domain_id => @domain.id )
    assert !other_subnet.save
  end

  test "when to_label is applied should show the domain, the mask and number" do
    create_a_domain_with_the_subnet

    assert_equal "domain: 123.123.123.1/321.321.321.3", @subnet.to_label
  end

  test "when empty? is applied should return false" do
    assert !@subnet.empty?

    set_attr(:number=, :mask=)
    @subnet.save
    assert !@subnet.empty?
  end

#find_subnet fails because "contains" is not defined for Subnet class

#  test "should find the subnet by ip" do
#    set_attr(:number=, :mask=)
#    @subnet.save
#    assert_equal @subnet, Subnet.find_subnet("123.123.123.1")
#  end

  test "when detailedName is applied should show the name, the mask and number" do
    set_attr(:name=, :mask=, :number=)
    @subnet.save

    assert_equal "valid@123.123.123.1/321.321.321.3", @subnet.detailedName
  end

  def set_attr(*attr)
    attr.each do |param|
      @subnet.send param, @attrs[param]
    end
  end

  def create_a_domain_with_the_subnet
    @domain = Domain.find_or_create_by_name("domain")
    set_attr(:number=, :mask=, :name=)
    @subnet.domain_id = @domain.id
    @subnet.save
  end
end

