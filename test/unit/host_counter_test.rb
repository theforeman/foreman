require "test_helper"

class HostCounterTest < ActiveSupport::TestCase
  def setup
    User.current = users :admin
  end

  def hosts_count(association)
    HostCounter.new(association)
  end

  let(:model) { FactoryBot.create(:model) }

  test 'it should get number of hosts associated to model' do
    FactoryBot.create(:host, model: model)
    count = hosts_count(:model)
    assert_equal 1, count[model]
  end

  test 'it should get number of hosts associated to architecture' do
    arch = FactoryBot.create(:architecture)
    FactoryBot.create_pair(:host, architecture: arch)
    count = hosts_count(:architecture)
    assert_equal 2, count[arch]
  end

  test 'it should count only hosts if user has view_hosts permissions' do
    FactoryBot.create(:host, model: model)

    as_admin do
      count = hosts_count(:model)
      assert_equal 1, count[model]
    end

    # user "one" does not have view hosts permissions
    as_user(:one) do
      count = hosts_count(:model)
      assert_equal 0, count[model]
    end
  end

  context 'with taxonomies' do
    let (:loc1) { taxonomies(:location1) }
    let (:loc2) { taxonomies(:location2) }
    let (:org1) { taxonomies(:organization1) }
    let (:org2) { taxonomies(:organization2) }

    setup do
      FactoryBot.create(:host, :model => model, :location => loc1, :organization => org1)
      FactoryBot.create(:host, :model => model, :location => loc2, :organization => org2)
    end

    test 'it should count only hosts in user location/organization' do
      assert_equal 2, hosts_count(:model)[model]

      Taxonomy.as_taxonomy(nil, loc1) do
        assert_equal 1, hosts_count(:model)[model]
      end

      Taxonomy.as_taxonomy(org1, nil) do
        assert_equal 1, hosts_count(:model)[model]
      end

      Taxonomy.as_taxonomy(org1, loc2) do
        assert_equal 0, hosts_count(:model)[model]
      end
    end

    test 'it should count hosts associated to location/organization even though current location/organization is set' do
      Taxonomy.as_taxonomy(org1, loc2) do
        assert_equal 2, hosts_count(:organization).hosts_count.count
        assert_equal 2, hosts_count(:location).hosts_count.count
      end
    end
  end

  context 'via primary_interface' do
    let(:domain) { FactoryBot.create(:domain) }

    test "should update hosts_count" do
      assert_difference "hosts_count(:domain)[domain]" do
        h = FactoryBot.create(:host)
        h.domain = domain
        h.save!
        domain.reload
      end
    end

    test "should update hosts_count on setting primary interface domain" do
      assert_difference "hosts_count(:domain)[domain]" do
        host = FactoryBot.create(:host, :managed, :ip => '127.0.0.1')
        primary = host.primary_interface
        primary.domain = domain
        primary.host.overwrite = true
        assert primary.save
        domain.reload
      end
    end

    test "should update hosts_count on changing primary interface domain" do
      host = FactoryBot.create(:host, :managed, :ip => '127.0.0.1')
      primary = host.primary_interface
      primary.domain = domain
      primary.host.overwrite = true
      assert primary.save
      assert_difference "hosts_count(:domain)[domain]", -1 do
        primary.domain = FactoryBot.create(:domain)
        assert primary.save
        domain.reload
      end
    end

    test "should update hosts_count on changing primarity of interface with domain" do
      host = FactoryBot.create(:host, :managed, :ip => '127.0.0.1')
      primary = host.primary_interface
      primary.domain = domain
      primary.host.overwrite = true
      assert primary.save
      assert_difference "hosts_count(:domain)[domain]", -1 do
        primary.update_attribute(:primary, false)
        domain.reload
      end
      assert_difference "hosts_count(:domain)[domain]" do
        primary.update_attribute(:primary, true)
        domain.reload
      end
    end

    test "should not update hosts_count on non-primary interface with domain" do
      assert_difference "hosts_count(:domain)[domain]", 0 do
        host = FactoryBot.create(:host, :managed, :ip => '127.0.0.1')
        FactoryBot.create(:nic_base, :primary => false, :domain => domain, :host => host)
        domain.reload
      end
    end

    test "should update hosts_count on domain_id change" do
      host = FactoryBot.create(:host, :managed, :domain => domain)
      assert_difference "hosts_count(:domain)[domain]", -1 do
        host.primary_interface.update_attribute(:domain_id, FactoryBot.create(:domain).id)
        domain.reload
      end
    end

    test "should update hosts_count on host destroy" do
      host = FactoryBot.create(:host, :managed, :domain => domain)
      assert_difference "hosts_count(:domain)[domain]", -1 do
        host.destroy
        domain.reload
      end
    end
  end
end
