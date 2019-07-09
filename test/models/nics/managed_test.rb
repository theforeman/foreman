require 'test_helper'

class ManagedTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  test '#setup_clone skips new records' do
    assert_nil FactoryBot.build(:nic_managed).send(:setup_clone)
  end

  test '#setup_clone clones host as well' do
    host = FactoryBot.create(:host, :comment => 'original')
    nic = FactoryBot.create(:nic_managed, :host => host)
    nic.host.comment = 'updated'
    clone = nic.send(:setup_clone)
    refute_equal clone.host.object_id, nic.host.object_id
    assert_equal 'updated', nic.host.comment
    assert_equal 'original', clone.host.comment
  end

  test "#normalize_hostname returns nil for empty names" do
    nic = setup_primary_nic_with_name('')
    assert_nil nic.send(:normalize_name)
  end

  # all tests that sues " Host..." as a name also checks that it removes whitespace and normalizes the hostname
  # this is because this method does too many things...
  test "#normalize_hostname sets a domain based on name that contains its name if it's nil and such domain exists" do
    domain = FactoryBot.create(:domain)
    nic = setup_primary_nic_with_name(" Host.#{domain.name}")
    nic.domain_id = nil
    nic.send(:normalize_name)
    assert_equal "host.#{domain.name}", nic.name
    assert_equal domain, nic.domain
  end

  test "#normalize_hostname keeps domain nil if it can't find such domain based on name" do
    domain = FactoryBot.create(:domain)
    nic = setup_primary_nic_with_name(" Host.#{domain.name}.custom", :domain => nil)
    nic.send(:normalize_name)
    assert_equal "host.#{domain.name}.custom", nic.name
    assert_nil nic.domain
  end

  test "#normalize_hostname keeps domain nil if it can't find such domain based on name" do
    nic = setup_primary_nic_with_name(" Host", :domain => nil)
    nic.send(:normalize_name)
    assert_equal "host", nic.name
    assert_nil nic.domain
  end

  test "#normalize_hostname does not touch name if it's different from domain name and it's a new record (leaves inconsistency)" do
    domain = FactoryBot.create(:domain)
    nic = setup_primary_nic_with_name(" Host.#{domain.name}.custom", :domain => domain)
    nic.send(:normalize_name)
    assert_equal "host.#{domain.name}.custom", nic.name
    assert_equal domain, nic.domain
  end

  test "#normalize_hostname updates name on existing record if domain changed" do
    domain = FactoryBot.create(:domain)
    nic = setup_primary_nic_with_name(" Host.#{domain.name}", :domain => domain)
    nic.host.save
    nic.reload

    new_domain = FactoryBot.create(:domain)
    nic.domain_id = new_domain.id
    nic.send(:normalize_name)
    assert_equal "host.#{new_domain.name}", nic.name
    assert_equal new_domain, nic.domain
  end

  test "#normalize_hostname does not update domain if domain does not match current taxonomies" do
    domain = FactoryBot.create(:domain)
    nic = setup_primary_nic_with_name(" Host.#{domain.name}", :domain => domain)
    nic.save!
    Location.current = taxonomies(:location2)
    User.as('one') do
      nic = Nic::Managed.find(nic.id) # load object to prevent cached association
      nic.send(:normalize_name)
      Location.current = nil
      assert_equal domain.id, nic.domain_id
    end
  end

  test "#inheriting_mac respects interface mac" do
    h = FactoryBot.build_stubbed(:host, :managed)
    h.primary_interface.mac = '11:22:33:44:55:66'
    assert_equal '11:22:33:44:55:66', h.primary_interface.inheriting_mac
  end

  test "#inheriting_mac respects interface mac even if attached_to is specified" do
    h = FactoryBot.build_stubbed(:host, :managed)
    h.primary_interface.mac = '11:22:33:44:55:66'
    h.primary_interface.identifier = 'eth0'
    n = h.interfaces.build :mac => '66:55:44:33:22:11', :attached_to => 'eth0'
    assert_equal '66:55:44:33:22:11', n.inheriting_mac
  end

  test "#inheriting_mac inherits mac if own mac is nil" do
    h = FactoryBot.build_stubbed(:host, :managed)
    h.primary_interface.mac = '11:22:33:44:55:66'
    h.primary_interface.identifier = 'eth0'
    n = h.interfaces.build :mac => nil, :attached_to => 'eth0'
    assert_equal '11:22:33:44:55:66', n.inheriting_mac
  end

  test "#inheriting_mac inherits mac if own mac is empty" do
    h = FactoryBot.build_stubbed(:host, :managed)
    h.primary_interface.mac = '11:22:33:44:55:66'
    h.primary_interface.identifier = 'eth0'
    n = h.interfaces.build :mac => '', :attached_to => 'eth0'
    assert_equal '11:22:33:44:55:66', n.inheriting_mac
  end

  context "there is a domain" do
    setup do
      @domain = FactoryBot.create(:domain)
    end

    test "host is invalid if two interfaces has same DNS name and domain" do
      h = FactoryBot.build_stubbed(:host, :managed)
      i1 = h.interfaces.build(:name => 'test')
      i2 = h.interfaces.build(:name => 'test')
      i1.domain_id = @domain.id
      i2.domain_id = @domain.id
      refute h.valid?
      assert h.interfaces.any? { |i| i.errors[:name].present? }
    end

    test "host is valid if two interfaces has different DNS name and same domain" do
      h = FactoryBot.build_stubbed(:host, :managed)
      i1 = h.interfaces.build(:name => 'test2')
      i2 = h.interfaces.build(:name => 'test')
      i1.domain_id = @domain.id
      i2.domain_id = @domain.id
      h.valid? # trigger validation
      assert h.interfaces.all? { |i| i.errors[:name].blank? }
    end

    test "host is valid if interfaces have blank name" do
      h = FactoryBot.build_stubbed(:host, :managed)
      h.interfaces.build(:name => '')
      h.interfaces.build(:name => '')
      h.valid? # trigger validation
      assert h.interfaces.all? { |i| i.errors[:name].blank? }
    end

    test "host is valid if two interfaces has same DNS name and different domain" do
      h = FactoryBot.build_stubbed(:host, :managed)
      domain2 = FactoryBot.create(:domain)
      i1 = h.interfaces.build(:name => 'test')
      i2 = h.interfaces.build(:name => 'test')
      i1.domain_id = @domain.id
      i2.domain_id = domain2.id
      h.valid? # trigger validation
      assert h.interfaces.all? { |i| i.errors[:name].blank? }
    end
  end

  context "with computeresource not in taxonomy scope" do
    let(:managed_host) { FactoryBot.build_stubbed(:host, :managed, :on_compute_resource) }
    let(:host_cr) { managed_host.compute_resource }

    setup do
      host_cr.update({ :locations => [taxonomies(:location2)],
                       :organizations => [taxonomies(:organization2)],
                    })
    end

    test 'host should be invalid via the interfaces compute_resource validation' do
      managed_host.interfaces.build(:name => 'test')
      refute managed_host.valid?
      assert managed_host.errors[:"interfaces.compute_resource_id"].present?
    end
  end

  private

  def setup_primary_nic_with_name(name, opts = {})
    h = FactoryBot.build(:host, :managed, opts) # build host, which also builds primary interface
    h.name = name                                # setup the desired name on host
    nic = h.primary_interface
    nic.valid?                                   # triggers copying hostname from host and normalize_name
    nic
  end
end
