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

    @subnet.mask = "255.255.255.0"
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

    other_subnet = Subnet.new( :mask => "111.111.111.1",
                                 :network => "255.255.252.0",
                                 :name => "valid",
                                 :domain_ids => [domains(:mydomain).id] )
    assert !other_subnet.valid?
    assert !other_subnet.save
  end

  test "when to_label is applied should show the domain, the mask and network" do
    create_a_domain_with_the_subnet

    assert_equal "123.123.123.1/24", @subnet.to_label
  end

  test "should find the subnet by ip" do
    @subnet = Subnet.new(:network => "123.123.123.1",:mask => "255.255.255.0",:name => "valid")
    assert @subnet.save
    assert @subnet.domain_ids = [domains(:mydomain).id]
    assert_equal @subnet, Subnet.subnet_for("123.123.123.1")
  end

  def set_attr(*attr)
    attr.each do |param|
      @subnet.send param, @attrs[param]
    end
  end

  def create_a_domain_with_the_subnet
    @domain = Domain.find_or_create_by_name("domain")
    @subnet = Subnet.new(:network => "123.123.123.1",:mask => "255.255.255.0",:name => "valid")
    assert @subnet.save
    assert @subnet.domain_ids = [domains(:mydomain).id]
    @subnet.save!
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
    record = Subnet.create :name => "dummy2", :network => "1.2.3.4", :mask => "255.255.255.0"
    assert record.domain_ids = [Domain.first.id]
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Subnet.new :name => "dummy", :network => "1.2.3.4", :mask => "255.255.255.0"
    assert record.valid?
    assert !record.save
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record = subnets(:two)
    as_admin do
      record.domains = []
      record.hosts.clear
      record.interfaces.clear
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

  test "should strip whitespace before save" do
    s = subnets(:one)
    s.network = " 10.0.0.22   "
    s.mask = " 255.255.255.0   "
    s.gateway = " 10.0.0.138   "
    s.dns_primary = " 10.0.0.50   "
    s.dns_secondary = " 10.0.0.60   "
    assert s.save
    assert_equal "10.0.0.22", s.network
    assert_equal "255.255.255.0", s.mask
    assert_equal "10.0.0.138", s.gateway
    assert_equal "10.0.0.50", s.dns_primary
    assert_equal "10.0.0.60", s.dns_secondary
  end

  test "should fix typo with extra dots to single dot" do
    s = subnets(:one)
    s.network = "10..0.0..22"
    assert s.save
    assert_equal "10.0.0.22", s.network
  end

  test "should fix typo with extra 5 after 255" do
    s = subnets(:one)
    s.mask = "2555.255.25555.0"
    assert s.save
    assert_equal "255.255.255.0", s.mask
  end

  test "should not allow an address great than 15 characters" do
    s = subnets(:one)
    s.mask = "255.255.255.1111"
    refute s.save
    assert_match /must be at most 15 characters/, s.errors.full_messages.join("\n")
  end

  test "should invalidate addresses are indeed invalid" do
    s = subnets(:one)
    # trailing dot
    s.network = "100.101.102.103."
    refute s.valid?
    # more than 3 characters
    s.network = "1234.101.102.103"
    # missing dot
    s.network = "100101.102.103."
    refute s.valid?
    # missing number
    s.network = "100.101.102"
    refute s.valid?
  end

end
