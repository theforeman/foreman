require 'test_helper'

class SubnetTest < ActiveSupport::TestCase
  def setup
    User.current = User.find_by_login "admin"
    @subnet = Subnet.new
    @attrs = {  :number= => "123.123.123.1",
      :mask= => "321.321.321.3",
      :name= => "valid" }
  end

  test "should have a number" do
    create_a_domain_with_the_subnet
    @subnet.number = nil
    assert !@subnet.save

    set_attr(:number=)
    assert @subnet.save
  end

  test "should have a mask" do
    create_a_domain_with_the_subnet
    @subnet.mask = nil
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

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_subnets"
      role.permissions = ["#{operation}_subnets".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  Subnet.create :name => "dummy", :number => "1.2.3.4", :mask => "255.255.255.0"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Subnet.create :name => "dummy", :number => "1.2.3.4", :mask => "255.255.255.0"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  Subnet.first
    as_admin do
      record.domain = nil
    end
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Subnet.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Subnet.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Subnet.first
    record.name = "renamed"
    as_admin do
      record.domain = nil
    end
    assert !record.save
    assert record.valid?
  end

end

