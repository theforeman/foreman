require 'test_helper'

class ManagedTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  test '#setup_clone skips new records' do
    assert_nil FactoryGirl.build(:nic_managed).send(:setup_clone)
  end

  test '#setup_clone clones host as well' do
    host = FactoryGirl.create(:host, :comment => 'original')
    nic = FactoryGirl.create(:nic_managed, :host => host)
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
    domain = FactoryGirl.create(:domain)
    nic = setup_primary_nic_with_name(" Host.#{domain.name}")
    nic.domain_id = nil
    nic.send(:normalize_name)
    assert_equal "host.#{domain.name}", nic.name
    assert_equal domain, nic.domain
  end

  test "#normalize_hostname keeps domain nil if it can't find such domain based on name" do
    domain = FactoryGirl.create(:domain)
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
    domain = FactoryGirl.create(:domain)
    nic = setup_primary_nic_with_name(" Host.#{domain.name}.custom", :domain => domain)
    nic.send(:normalize_name)
    assert_equal "host.#{domain.name}.custom", nic.name
    assert_equal domain, nic.domain
  end

  test "#normalize_hostname updates name on existing record if domain changed" do
    domain = FactoryGirl.create(:domain)
    nic = setup_primary_nic_with_name(" Host.#{domain.name}", :domain => domain)
    nic.host.save
    nic.reload

    new_domain = FactoryGirl.create(:domain)
    nic.domain_id = new_domain.id
    nic.send(:normalize_name)
    assert_equal "host.#{new_domain.name}", nic.name
    assert_equal new_domain, nic.domain
  end

  test "#inheriting_mac respects interface mac" do
    h = FactoryGirl.build(:host, :managed)
    h.primary_interface.mac = '11:22:33:44:55:66'
    assert_equal '11:22:33:44:55:66', h.primary_interface.inheriting_mac
  end

  test "#inheriting_mac respects interface mac even if attached_to is specified" do
    h = FactoryGirl.build(:host, :managed)
    h.primary_interface.mac = '11:22:33:44:55:66'
    h.primary_interface.identifier = 'eth0'
    n = h.interfaces.build :mac => '66:55:44:33:22:11', :attached_to => 'eth0'
    assert_equal '66:55:44:33:22:11', n.inheriting_mac
  end

  test "#inheriting_mac inherits mac if own mac is nil" do
    h = FactoryGirl.build(:host, :managed)
    h.primary_interface.mac = '11:22:33:44:55:66'
    h.primary_interface.identifier = 'eth0'
    n = h.interfaces.build :mac => nil, :attached_to => 'eth0'
    assert_equal '11:22:33:44:55:66', n.inheriting_mac
  end

  test "#inheriting_mac inherits mac if own mac is empty" do
    h = FactoryGirl.build(:host, :managed)
    h.primary_interface.mac = '11:22:33:44:55:66'
    h.primary_interface.identifier = 'eth0'
    n = h.interfaces.build :mac => '', :attached_to => 'eth0'
    assert_equal '11:22:33:44:55:66', n.inheriting_mac
  end

  test "#identifier_change ignores any identifier changes for new record" do
    host = FactoryGirl.build(:host)
    nic = FactoryGirl.build(:nic_managed, :host => host)
    assert nic.valid?
    %w(eth0 eth0.1 eth0:0).each do |valid|
      nic.identifier = valid
      assert nic.valid?
    end
  end

  test "#identifier_change prevents manipulating dots and commas in identifier for existing record" do
    host = FactoryGirl.create(:host)
    [ ['eth0', ['eth0.1', 'eth0:0'], ['eth1']],
      ['eth0.1', ['eth0:0', 'eth0'], ['eth1.1']],
      ['eth0:0', ['eth0.1', 'eth0'], ['eth0:1']] ].each do |existing, invalids, valids|
      nic = FactoryGirl.create(:nic_managed, :identifier => existing, :host => host)

      invalids.each do |invalid|
        nic.identifier = invalid
        refute nic.valid?, "expected NIC identifier #{invalid} to be invalid after change from #{existing}"
        assert nic.errors.messages.has_key?(:identifier), "expected NIC identifier #{invalid} to be invalid after change from #{existing}"
      end

      valids.each do |valid|
        nic.identifier = valid
        nic.valid? # just trigger the validation to populate errors
        refute nic.errors.messages.has_key?(:identifier), "expected NIC identifier #{valid} to be valid after change from #{existing}"
      end
    end
  end

  context "there is a domain" do
    setup do
      @domain = FactoryGirl.create(:domain)
    end

    test "host is invalid if two interfaces has same DNS name and domain" do
      h = FactoryGirl.build(:host, :managed)
      i1 = h.interfaces.build(:name => 'test')
      i2 = h.interfaces.build(:name => 'test')
      i1.domain_id = @domain.id
      i2.domain_id = @domain.id
      refute h.valid?
      assert h.interfaces.any? { |i| i.errors[:name].present? }
    end

    test "host is valid if two interfaces has different DNS name and same domain" do
      h = FactoryGirl.build(:host, :managed)
      i1 = h.interfaces.build(:name => 'test2')
      i2 = h.interfaces.build(:name => 'test')
      i1.domain_id = @domain.id
      i2.domain_id = @domain.id
      h.valid? # trigger validation
      assert h.interfaces.all? { |i| i.errors[:name].blank? }
    end

    test "host is valid if interfaces have blank name" do
      h = FactoryGirl.build(:host, :managed)
      h.interfaces.build(:name => '')
      h.interfaces.build(:name => '')
      h.valid? # trigger validation
      assert h.interfaces.all? { |i| i.errors[:name].blank? }
    end

    test "host is valid if two interfaces has same DNS name and different domain" do
      h = FactoryGirl.build(:host, :managed)
      domain2 = FactoryGirl.create(:domain)
      i1 = h.interfaces.build(:name => 'test')
      i2 = h.interfaces.build(:name => 'test')
      i1.domain_id = @domain.id
      i2.domain_id = domain2.id
      h.valid? # trigger validation
      assert h.interfaces.all? { |i| i.errors[:name].blank? }
    end
  end

  private

  def setup_primary_nic_with_name(name, opts = {})
    h = FactoryGirl.build(:host, :managed, opts) # build host, which also builds primary interface
    h.name = name                                # setup the desired name on host
    nic = h.primary_interface
    nic.valid?                                   # triggers copying hostname from host and normalize_name
    nic
  end
end
