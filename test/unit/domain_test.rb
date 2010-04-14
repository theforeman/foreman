require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def setup
    @new_domain = Domain.new
    @domain = Domain.new(:name => "myDomain")
    @domain.save
  end

  test "should not save without a name" do
    assert !@new_domain.save
  end

  test "should exists a unique name" do
    other_domain = Domain.new(:name => "myDomain")
    assert !other_domain.save
  end

  test "should exists a unique fullname" do
    @domain.fullname = "full_name"
    @domain.save

    other_domain = Domain.new(:name => "otherDomain", :fullname => "full_name")
    assert !other_domain.save
  end

  test "the dnsserver name should not contain spaces" do
    @domain.dnsserver = "this contains spaces"
    assert !@domain.save
  end

  test "the gateway name should not contain spaces" do
    @domain.gateway = "this contains spaces"
    assert !@domain.save
  end

  test "when cast to string should return the name" do
    s = @domain.to_s
    assert_equal @domain.name, s
  end

  test "should not destroy if have childrens" do
    host = create_a_host

    d = host.domain
    assert !d.destroy

    subnet = Subnet.create  :number => "123.123.123.1", :mask => "321.321.321.1",
                             :domain => @domain

    d = subnet.domain
    assert !d.destroy
  end

#I must find out how to create a fact_name inside of fact_value

#  test "should counts how many times a fact value exists in this domain" do
#    host = create_a_host
#    host.fact_values = FactValue.create(:fact_name)
#  end

  def create_a_host
    Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
                 :domain => @domain,
                 :operatingsystem => Operatingsystem.first,
                 :architecture => Architecture.find_or_create_by_name("i386"),
                 :environment => Environment.find_or_create_by_name("envy"),
                 :disk => "empty partition"
  end
end

