require 'test_helper'

class AuditExtensionsTest < ActiveSupport::TestCase
  def setup
    @user = users :admin
  end

  test "should be connected to current user" do
    audit = as_admin do
      FactoryBot.create(:audit)
    end

    assert_equal audit.user_id, @user.id
    assert_equal audit.username, @user.name
  end

  test "audit's change is filtered when data is encrypted" do
    Setting.any_instance.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    setting = Foreman.settings.set_user_value('root_pass', '654321')
    as_admin do
      assert setting.save
    end
    a = Audit.where(auditable_type: 'Setting')
    assert_equal "[redacted]", a.last.audited_changes["value"][1]
  end

  context "with multiple taxonomies" do
    def setup
      @loc = taxonomies(:location1)
      @org = taxonomies(:organization1)
    end

    test 'records on create' do
      domain = FactoryBot.create(:domain, :with_auditing, :locations => [@loc], :organizations => [@org])
      audit = domain.audits.last
      assert_equal 'create', audit.action
      assert_equal [@loc.id], audit.location_ids
      assert_equal [@org.id], audit.organization_ids
    end

    test 'sets no current taxonomies for audits on none-taxable resources (like Architecture)' do
      Taxonomy.as_taxonomy(@org, @loc) do
        arch = FactoryBot.create(:architecture, :with_auditing)
        audit = arch.audits.last
        assert_not audit.location_ids.include? @loc
        assert_not audit.organization_ids.include? @org
      end
    end

    test 'records on update' do
      domain = FactoryBot.create(:domain, :with_auditing, :locations => [], :organizations => [])
      audit = domain.audits.last
      assert_equal 'create', audit.action
      assert_equal [], audit.location_ids
      assert_equal [], audit.organization_ids

      domain.name = 'blablabla' # needed for a new audit to be generated
      domain.locations = [@loc]
      domain.organizations = [@org]
      domain.save!
      audit = domain.audits.last
      assert_equal 'update', audit.action
      assert_equal [@loc.id], audit.location_ids
      assert_equal [@org.id], audit.organization_ids
    end

    test 'records on destroy' do
      domain = FactoryBot.create(:domain, :with_auditing, :locations => [@loc], :organizations => [@org])
      domain.destroy
      audit = domain.audits.last
      assert_equal 'destroy', audit.action
      assert_equal [@loc.id], audit.location_ids
      assert_equal [@org.id], audit.organization_ids
    end
  end

  context "with single taxonomy" do
    def setup
      @loc = taxonomies(:location1)
      @org = taxonomies(:organization1)
    end

    test 'records on create' do
      host = FactoryBot.create(:host, :with_auditing, :location => @loc, :organization => @org)
      audit = host.audits.last
      assert_equal 'create', audit.action
      assert_equal [@loc.id], audit.location_ids
      assert_equal [@org.id], audit.organization_ids
    end

    test 'records on update' do
      host = FactoryBot.create(:host, :with_auditing, :location => nil, :organization => nil)
      audit = host.audits.last
      assert_equal 'create', audit.action
      assert_equal [], audit.location_ids
      assert_equal [], audit.organization_ids

      host.location_id = @loc.id
      host.organization_id = @org.id
      host.save!
      audit = host.audits.last
      assert_equal 'update', audit.action
      assert_equal [@loc.id], audit.location_ids
      assert_equal [@org.id], audit.organization_ids

      host.location_id = taxonomies(:location2).id
      host.organization_id = taxonomies(:organization2).id
      host.save!
      audit = host.audits.last
      assert_equal 'update', audit.action
      assert_equal [@loc.id, taxonomies(:location2).id], audit.location_ids
      assert_equal [@org.id, taxonomies(:organization2).id], audit.organization_ids
    end

    test 'records on destroy' do
      host = FactoryBot.create(:host, :with_auditing, :location => @loc, :organization => @org)
      host.destroy
      audit = host.audits.last
      assert_equal 'destroy', audit.action
      assert_equal [@loc.id], audit.location_ids
      assert_equal [@org.id], audit.organization_ids
    end
  end

  describe 'taxables' do
    subject { Audit }
    setup do
      auditable_types = [Organization, Location, Architecture, Domain, Nic::Managed]
      Audit.stubs(:known_auditable_types).returns(auditable_types)
    end

    context 'as user' do
      setup do
        @save_user = User.current
        User.current = users(:one)
      end

      test '.location_taxable' do
        location_taxables = subject.location_taxable

        assert_includes location_taxables, Organization
        refute_includes location_taxables, Location
        refute_includes location_taxables, Architecture
        refute_includes location_taxables, Domain
        refute_includes location_taxables, Nic::Managed
      end

      test '.organization_taxable' do
        organization_taxables = subject.organization_taxable
        assert_includes organization_taxables, Location
        refute_includes organization_taxables, Organization
        refute_includes organization_taxables, Architecture
        refute_includes organization_taxables, Domain
        refute_includes organization_taxables, Nic::Managed
      end

      test '.fully_taxable' do
        fully_taxables = subject.fully_taxable
        assert_includes fully_taxables, Domain
        refute_includes fully_taxables, Location
        refute_includes fully_taxables, Organization
        refute_includes fully_taxables, Architecture
        refute_includes fully_taxables, Nic::Managed
      end

      test '.untaxable' do
        untaxables = subject.untaxable
        assert_includes untaxables, Architecture
        refute_includes untaxables, Nic::Managed
        refute_includes untaxables, Domain
        refute_includes untaxables, Location
        refute_includes untaxables, Organization
      end
    end

    context 'as_admin' do
      setup do
        @save_user = User.current
        User.current = users(:admin)
      end

      test '.untaxable should have Nic::Managed' do
        untaxables = subject.untaxable
        assert_includes untaxables, Nic::Managed
        refute_includes untaxables, Domain
      end
    end

    teardown do
      User.current = @save_user
    end
  end

  describe 'taxonomies for audits' do
    let(:loc1) { FactoryBot.create(:location) }
    let(:loc2) { FactoryBot.create(:location) }
    let(:org1) { FactoryBot.create(:organization) }
    let(:org2) { FactoryBot.create(:organization) }
    let(:user1) { FactoryBot.create(:user, :locations => [loc1], :organizations => [org1]) }
    let(:user2) { FactoryBot.create(:user, :locations => [loc2], :organizations => [org2]) }
    let(:domain1_audit) { FactoryBot.create(:audit, :organizations => [org1], :locations => [loc1], :auditable_type => 'Domain') }
    let(:domain2_audit) { FactoryBot.create(:audit, :organizations => [org2], :locations => [loc2], :auditable_type => 'Domain') }
    let(:domain12_audit) { FactoryBot.create(:audit, :organizations => [org1], :locations => [loc2], :auditable_type => 'Domain') }
    let(:domain21_audit) { FactoryBot.create(:audit, :organizations => [org2], :locations => [loc1], :auditable_type => 'Domain') }
    let(:domain01_audit) { FactoryBot.create(:audit, :locations => [loc1], :auditable_type => 'Domain') }
    let(:domain10_audit) { FactoryBot.create(:audit, :organizations => [org1], :auditable_type => 'Domain') }
    let(:architecture_audit) { FactoryBot.create(:audit, :organizations => [], :locations => [], :auditable_type => 'Architecture') }
    let(:organization_audit) { FactoryBot.create(:audit, :auditable_type => 'Organization', :organizations => [], :locations => [loc1]) }
    let(:location_audit) { FactoryBot.create(:audit, :auditable_type => 'Location', :organizations => [org1], :locations => []) }
    let(:location2_audit) { FactoryBot.create(:audit, :auditable_type => 'Location', :organizations => [org2], :locations => []) }
    let(:lazy_load) do
      [architecture_audit, domain1_audit, domain2_audit, domain12_audit, domain21_audit, domain01_audit, domain10_audit, organization_audit, location_audit, location2_audit]
    end

    test ".untaxed" do
      lazy_load

      Taxonomy.as_taxonomy(org1, loc1) do
        as_user(user1) do
          result = Audit.untaxed.all
          assert_includes result, architecture_audit
          refute_includes result, domain1_audit
          refute_includes result, domain2_audit
          refute_includes result, domain12_audit
          refute_includes result, domain21_audit
          refute_includes result, domain01_audit
          refute_includes result, domain10_audit
        end
      end

      Taxonomy.as_taxonomy(org2, loc2) do
        as_user(user2) do
          result = Audit.untaxed.all
          assert_includes result, architecture_audit
          refute_includes result, domain1_audit
          refute_includes result, domain2_audit
          refute_includes result, domain12_audit
          refute_includes result, domain21_audit
          refute_includes result, domain01_audit
          refute_includes result, domain10_audit
        end
      end
    end

    test ".taxed_only_by_location" do
      lazy_load

      Taxonomy.as_taxonomy(org1, loc1) do
        as_user(user1) do
          result = Audit.taxed_only_by_location.all
          assert_includes result, organization_audit
          refute_includes result, architecture_audit
          refute_includes result, domain1_audit
        end
      end
    end

    test ".taxed_only_by_organization" do
      lazy_load

      Taxonomy.as_taxonomy(org1, loc1) do
        as_user(user1) do
          result = Audit.taxed_only_by_organization.all
          assert_includes result, location_audit
          refute_includes result, architecture_audit
          refute_includes result, domain1_audit
        end
      end
    end
    test ".taxed_and_untaxed" do
      lazy_load

      Taxonomy.as_taxonomy(org1, loc1) do
        as_user(user1) do
          result = Audit.taxed_and_untaxed
          assert_includes result, domain1_audit
          refute_includes result, domain2_audit
          refute_includes result, domain12_audit
          refute_includes result, domain21_audit
          refute_includes result, domain01_audit
          refute_includes result, domain10_audit
          assert_includes result, architecture_audit
          assert_includes result, organization_audit
          assert_includes result, location_audit
          refute_includes result, location2_audit
        end
      end
    end
  end

  describe "#main_object_names" do
    test "should contain 'Host::Base' classname along with audited_classes" do
      host = FactoryBot.create(:host, :managed, :with_auditing)
      audit = host.audits.last
      assert_equal 'create', audit.action
      assert_equal 'Host::Base', audit.auditable_type
      assert_include Audit.main_object_names, audit.auditable_type
    end
  end
end
