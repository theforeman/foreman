require 'test_helper'

class RealmTest < ActiveSupport::TestCase
  def setup
    User.current = users(:admin)
    @new_realm = Realm.new
    @realm = realms(:myrealm)
  end

  test "should not save without a name" do
    assert !@new_realm.save
  end

  test "should exists a unique name" do
    other_realm = Realm.new(:name => "myrealm.net")
    assert !other_realm.save
  end

  test "when cast to string should return the name" do
    s = @realm.to_s
    assert_equal @realm.name, s
  end

  test "should not destroy if it contains hosts" do
    disable_orchestration
    host = FactoryGirl.create(:host, :realm => @realm)

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
    FactoryGirl.create(:host, :realm => @realm,
                       :location => taxonomies(:location1))
    assert_equal [taxonomies(:location1).id], realms(:myrealm).used_location_ids
  end

  test "should get used and selected location ids for host" do
    assert_equal [taxonomies(:location1).id], realms(:myrealm).used_or_selected_location_ids
  end
end

