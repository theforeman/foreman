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

  test "if destroy not leave orphan childrens" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
                        :domain => Domain.find_or_create_by_name("domain"),
                        :operatingsystem => Operatingsystem.create(:name => "linux", :major => 389),
                        :architecture => Architecture.find_or_create_by_name("i386"),
                        :environment => Environment.find_or_create_by_name("envy"),
                        :disk => "empty partition"

    d = host.domain
    assert !d.destroy

    subnet = Subnet.create  :number => "123.123.123.1", :mask => "321.321.321.1",
                             :domain => Domain.find_or_create_by_name("domain")

    d = subnet.domain
    assert !d.destroy
  end
end

