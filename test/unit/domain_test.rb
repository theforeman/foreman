require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def setup
    User.current = users(:admin)
    @new_domain = Domain.new
    @domain = domains(:mydomain)
  end

  test "should not save without a name" do
    assert !@new_domain.save
  end

  test "should exists a unique name" do
    other_domain = Domain.new(:name => "mydomain.net")
    assert !other_domain.save
  end

  test "should exists a unique fullname" do
    @domain.fullname = "full_name"
    @domain.save

    other_domain = Domain.new(:name => "otherDomain", :fullname => "full_name")
    assert !other_domain.save
  end

  test "when cast to string should return the name" do
    s = @domain.to_s
    assert_equal @domain.name, s
  end

  test "should not destroy if it contains hosts" do
    disable_orchestration
    host = create_a_host
    assert host.save

    domain = host.domain
    assert !domain.destroy
    assert_match /is used by/, domain.errors.full_messages.join("\n")
  end

  test "should not destroy if it contains subnets" do

    as_admin do
      Subnet.create! :network => "123.123.123.1", :mask => "255.255.255.0",
                     :domains => [@domain], :name => "test subnet"
    end
    assert !@domain.destroy
    assert_match /is used by/, @domain.errors.full_messages.join("\n")
  end

  test "domain can be assigned to locations" do
    location1 = Location.create :name => "Zurich"
    assert location1.save!

    location2 = Location.create :name => "Switzerland"
    assert location2.save!

    domain = Domain.create :name => "test.net"
    domain.locations = []
    domain.locations.push location1
    domain.locations.push location2
    assert domain.save!
  end

#I must find out how to create a fact_name inside of fact_value

#  test "should counts how many times a fact value exists in this domain" do
#    host = create_a_host
#    host.fact_values = FactValue.create(:fact_name)
#  end

  def create_a_host
    hosts(:one)
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_domains"
      role.permissions = ["#{operation}_domains".to_sym]
      @one.roles = [role]
      @one.domains = []
      @one.save!
    end
    User.current = @one
  end

  test "user with edit permissions should be able to edit when permitted" do
    setup_user "edit"
    as_admin do
      @one.domains = [domains(:mydomain)]
    end
    record =  Domain.find_by_name "mydomain.net"
    assert record.update_attributes(:name => "testing")
    assert record.valid?
  end

  test "user with edit permissions should not be able to edit when not permitted" do
    setup_user "edit"
    as_admin do
      @one.domains = [domains(:yourdomain)]
    end
    record =  Domain.find_by_name "mydomain.net"
    assert !record.update_attributes(:name => "testing")
    assert record.valid?
  end

  test "user with edit permissions should be able to edit when unconstrained" do
    setup_user "edit"
    record =  Domain.first
    assert record.update_attributes(:name => "testing")
    assert record.valid?
  end

  test "user with view permissions should not be able to create when not permitted" do
    setup_user "view"
    record =  Domain.create :name => "dummy", :fullname => "dummy.com"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record = domains(:useless)
    record.interfaces.clear
    record.hosts.clear
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Domain.first
    record.subnets.clear
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Domain.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Domain.first
    record.name = "renamed"
    assert !record.save
  end

  test "should query local nameservers when enabled" do
    Setting['query_local_nameservers'] = true
    assert Domain.first.nameservers.empty?
  end

  test "should query remote nameservers" do
    assert Domain.first.nameservers.empty?
  end
end

