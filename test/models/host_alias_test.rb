require 'test_helper'

class HostAliasTest < ActiveSupport::TestCase
  should belong_to(:domain)
  should belong_to(:nic)

  should validate_presence_of(:name)
  should validate_presence_of(:nic_id)

  setup do
    disable_orchestration
  end

  test '#host_alias should build' do
    h = HostAlias.new(:name => 'my_alias')
    h.valid?
    assert_equal 'my_alias', h.name
  end

  test '#host_alias should belong to a domain ' do
    h = HostAlias.new(:name => 'my_alias',
                      :domain => FactoryGirl.build(:domain, :name => 'example.com'))
    h.valid?
    assert_equal 'example.com', h.domain.name
  end

  test '#nic should have many host_aliases' do
    nic = FactoryGirl.build(:nic_base)
    nic.host_aliases << FactoryGirl.build(:host_alias)
    nic.host_aliases << FactoryGirl.build(:host_alias)
    nic.valid?
    assert_equal 2, nic.host_aliases.size
  end

  test '#nic should have host_aliases in distincts domains' do
    nic = FactoryGirl.build(:nic_managed,
                            :host   => FactoryGirl.create(:host),
                            :domain => FactoryGirl.create(:domain))
    nic.host_aliases << FactoryGirl.build(:host_alias)

    distinct_domain = FactoryGirl.create(:domain)
    nic.host_aliases << FactoryGirl.build(:host_alias, :domain => distinct_domain)

    refute_equal nic.host_aliases[0].domain,
                 nic.host_aliases[1].domain

  end
end
