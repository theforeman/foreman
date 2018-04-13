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
    setting = settings(:attributes63)
    setting.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    setting.value = '654321'
    as_admin do
      assert setting.save
    end
    a = Audit.where(auditable_type: 'Setting')
    assert_equal "[redacted]", a.last.audited_changes["value"][1]
  end

  test "audited changes field can be greater then 65K bytes" do
    prov_template = templates(:mystring)
    prov_template.template = "0000000000" * 3500
    as_admin do
      assert prov_template.save!
      prov_template.template = "1111111111" * 3500
      assert prov_template.save!
    end
    assert Audit.last.audited_changes.to_s.bytesize > 66000
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
end
