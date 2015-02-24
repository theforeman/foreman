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

  private

  def setup_primary_nic_with_name(name, opts = {})
    h = FactoryGirl.build(:host, :managed, opts) # build host, which also builds primary interface
    h.name = name                                # setup the desired name on host
    nic = h.primary_interface
    nic.valid?                                   # triggers copying hostname from host and normalize_name
    nic
  end
end
