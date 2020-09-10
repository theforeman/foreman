require 'test_helper'

class RealmTest < ActiveSupport::TestCase
  def setup
    User.current = users(:admin)
    @new_realm = Realm.new
    @realm = realms(:myrealm)
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should have_many(:locations).
    source(:taxonomy).
    conditions(:type => 'Location').
    through(:taxable_taxonomies)
  should belong_to(:realm_proxy)

  test "when cast to string should return the name" do
    assert_equal @realm.name, @realm.to_s
  end

  test "should not destroy if it contains hosts" do
    disable_orchestration
    host = FactoryBot.create(:host, :realm => @realm)
    assert host.save
    realm = host.realm
    assert !realm.destroy
    assert_match /is used by/, realm.errors.full_messages.join("\n")
  end

  test "realm can be assigned to locations" do
    location1 = Location.create :name => "Zurich"
    assert location1.save!

    location2 = Location.create :name => "Switzerland"
    assert location2.save!

    realm = Realm.create :name => "test.net", :realm_proxy => smart_proxies(:realm), :realm_type => "FreeIPA"
    realm.locations.destroy_all
    realm.locations.push location1
    realm.locations.push location2
    assert realm.save!
  end

  # test taxonomix methods
  test "should get used location ids for host" do
    FactoryBot.create(:host, :realm => @realm,
                       :location => taxonomies(:location1))
    assert_equal [taxonomies(:location1).id], realms(:myrealm).used_location_ids
  end

  test "should get used and selected location ids for host" do
    assert_equal [taxonomies(:location1).id], realms(:myrealm).used_or_selected_location_ids
  end

  test "should not assign proxy without realm feature" do
    proxy = smart_proxies(:two)
    realm = Realm.new(:name => ".otherDomain.", :realm_type => "FreeIPA", :realm_proxy_id => proxy.id)
    refute realm.save
    assert_equal "does not have the Realm feature", realm.errors["realm_proxy_id"].first
  end
end
