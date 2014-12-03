require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def setup
    User.current = users(:admin)
    @new_domain = Domain.new
    @domain = domains(:mydomain)
    Domain.all.each do |d| #because we load from fixtures, counters aren't updated
      Domain.reset_counters(d.id,:hosts)
      Domain.reset_counters(d.id,:hostgroups)
    end

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

  test "should update hosts_count" do
    domain = domains(:yourdomain)
    assert_difference "domain.hosts_count" do
      FactoryGirl.create(:host).update_attribute(:domain, domain)
      domain.reload
    end
  end

  test "should update hosts_count on domain_id change" do
    domain = domains(:yourdomain)
    assert_difference "domain.hosts_count" do
      FactoryGirl.create(:host).update_attribute(:domain_id, domain.id)
      domain.reload
    end
  end

  test "should update hostgroups_count" do
    domain = domains(:yourdomain)
    assert_difference "domain.hostgroups_count" do
      hostgroups(:common).update_attribute(:domain, domain)
      domain.reload
    end
  end

#I must find out how to create a fact_name inside of fact_value

#  test "should counts how many times a fact value exists in this domain" do
#    host = create_a_host
#    host.fact_values = FactValue.create(:fact_name)
#  end

  def create_a_host
    FactoryGirl.create(:host)
  end

  test "should query local nameservers when enabled" do
    Setting['query_local_nameservers'] = true
    assert Domain.first.nameservers.empty?
  end

  test "should query remote nameservers" do
    assert Domain.first.nameservers.empty?
  end

  # test taxonomix methods
  test "should get used location ids for host" do
    FactoryGirl.create(:host, :domain => domains(:mydomain), :location => taxonomies(:location1))
    assert_equal [taxonomies(:location1).id], domains(:mydomain).used_location_ids
  end

  test "should get used and selected location ids for host" do
    assert_equal [taxonomies(:location1).id], domains(:mydomain).used_or_selected_location_ids
  end

end

