require 'test_helper'

class SubnetTest < ActiveSupport::TestCase
  def setup
    User.current = User.find_by_login "admin"
    @subnet = Subnet.new
    @attrs = {  :network= => "123.123.123.1",
      :mask= => "255.255.255.0",
      :domains= => [domains(:mydomain)],
      :name= => "valid" }
  end

  test "should have a network" do
    create_a_domain_with_the_subnet
    @subnet.network = nil
    assert !@subnet.save

    set_attr(:network=)
    assert @subnet.save
  end

  test "should have a mask" do
    create_a_domain_with_the_subnet
    @subnet.mask = nil
    assert !@subnet.save

    set_attr(:mask=)
    assert @subnet.save
  end

  test "network should have ip format" do
    @subnet.network = "asf.fwe6.we6s.q1"
    set_attr(:mask=)
    assert !@subnet.save
  end

  test "mask should have ip format" do
    @subnet.mask = "asf.fwe6.we6s.q1"
    set_attr(:network=, :domains=, :name=)
    assert !@subnet.save
  end

  test "network should be unique" do
    set_attr(:network=, :mask=, :domains=, :name=)
    @subnet.save

    other_subnet = Subnet.create(:network => "123.123.123.1", :mask => "255.255.255.0")
    assert !other_subnet.save
  end

  test "the name should be unique in the domain scope" do
    create_a_domain_with_the_subnet

    other_subnet = Subnet.create( :mask => "111.111.111.1",
                                 :network => "255.255.252.0",
                                 :name => "valid",
                                 :domains => [@domain] )
    other_subnet.valid?
    assert !other_subnet.save
  end

  test "when to_label is applied should show the domain, the mask and network" do
    create_a_domain_with_the_subnet

    assert_equal "123.123.123.1/24", @subnet.to_label
  end

  test "should find the subnet by ip" do
    set_attr(:network=, :mask=, :domains=, :name=)
    assert @subnet.save
    assert_equal @subnet, Subnet.subnet_for("123.123.123.1")
  end

  def set_attr(*attr)
    attr.each do |param|
      @subnet.send param, @attrs[param]
    end
  end

  def create_a_domain_with_the_subnet
    @domain = Domain.find_or_create_by_name("domain")
    set_attr(:network=, :mask=, :name=)
    @subnet.domains = [@domain]
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
    record = Subnet.create :name => "dummy2", :network => "1.2.3.4", :mask => "255.255.255.0", :domains => [Domain.first]
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Subnet.create :name => "dummy", :network => "1.2.3.4", :mask => "255.255.255.0", :domains => [Domain.first]
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record = subnets(:two)
    as_admin do
      record.domains = []
      record.hosts.clear
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
      record.domains = [domains(:unuseddomain)]
    end
    assert !record.save
    assert record.valid?
  end

  test "from cant be bigger than to range" do
    s      = subnets(:one)
    s.to   = "2.3.4.15"
    s.from = "2.3.4.17"
    assert !s.save
  end

  test "should be able to save ranges" do
    s=subnets(:one)
    s.from = "2.3.4.15"
    s.to   = "2.3.4.17"
    assert s.save
  end

  test "should not be able to save ranges if they dont belong to the subnet" do
    s=subnets(:one)
    s.from = "2.3.3.15"
    s.to   = "2.3.4.17"
    assert !s.save
  end

  test "should not be able to save ranges if one of them is missing" do
    s=subnets(:one)
    s.from = "2.3.4.15"
    assert !s.save
    s.to   = "2.3.4.17"
    assert s.save
  end

end
