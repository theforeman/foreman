require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
    User.current = users(:admin)
    @new_domain = Domain.new
    @domain = domains(:mydomain)
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should validate_uniqueness_of(:fullname).allow_nil
  should validate_uniqueness_of(:fullname).allow_blank
  should belong_to(:dns)

  test "when cast to string should return the name" do
    s = @domain.to_s
    assert_equal @domain.name, s
  end

  test "should remove leading and trailing dot from name" do
    other_domain = Domain.new(:name => ".otherDomain.", :fullname => "full_name")
    assert other_domain.valid?
    other_domain.save
    assert_equal "otherDomain", other_domain.name
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
    @domain.subnets.clear
    assert @domain.subnets.empty?
    @domain.subnets << Subnet.first
    assert !@domain.destroy
    assert_match /is used by/, @domain.errors.full_messages.join("\n")
  end

  test "domain can be assigned to locations" do
    location1 = Location.create :name => "Zurich"
    assert location1.save!

    location2 = Location.create :name => "Switzerland"
    assert location2.save!

    domain = Domain.create :name => "test.net"
    domain.locations.destroy_all
    domain.locations.push location1
    domain.locations.push location2
    assert domain.save!
  end

  # I must find out how to create a fact_name inside of fact_value

  #  test "should counts how many times a fact value exists in this domain" do
  #    host = create_a_host
  #    host.fact_values = FactValue.create(:fact_name)
  #  end

  def create_a_host
    FactoryBot.create(:host, :domain => FactoryBot.build(:domain))
  end

  test "should query local nameservers when enabled" do
    Setting['query_local_nameservers'] = true
    assert Domain.first.nameservers.empty?
  end

  test "should query remote nameservers from domain SOA" do
    domain = FactoryBot.build_stubbed(:domain)

    ns = mock
    ns.expects(:mname).returns('10.1.1.1')

    resolv = mock('Resolv::DNS')
    resolv.expects(:getresources).with(domain.name, Resolv::DNS::Resource::IN::SOA).returns([ns])
    Resolv::DNS.expects(:new).returns(resolv)

    assert_equal ['10.1.1.1'], domain.nameservers
  end

  # test taxonomix methods
  test "should get used location ids for host" do
    FactoryBot.create(:host, :domain => domains(:mydomain), :location => taxonomies(:location1))
    assert_equal [taxonomies(:location1).id], domains(:mydomain).used_location_ids
  end

  test "should get used and selected location ids for host" do
    assert_equal [taxonomies(:location1).id], domains(:mydomain).used_or_selected_location_ids
  end

  test "should not assign proxy without dns feature" do
    proxy = smart_proxies(:two)
    domain = Domain.new(:name => ".otherDomain.", :fullname => "full_name", :dns_id => proxy.id)
    refute domain.save
    assert_equal "does not have the DNS feature", domain.errors["dns_id"].first
  end

  test "can search domains by params" do
    domain = Domain.new(:name => ".localDomain.", :fullname => "full_name")
    domain.domain_parameters << DomainParameter.create(:name => "local", :value => "example", :parameter_type => 'string')
    assert domain.save!

    parameter = domain.domain_parameters.first
    results = Domain.search_for(%{params.#{parameter.name} = "#{parameter.searchable_value}"})
    assert results.include?(domain)
  end
end
