require 'test_helper'

class HostAliasTest < ActiveSupport::TestCase
  should belong_to(:domain)
  should belong_to(:nic)

  should validate_presence_of(:name)
  should validate_presence_of(:nic_id)

  setup do
    disable_orchestration
  end

  test '#host_alias should be created' do
    ha = FactoryGirl.create(:host_alias)
    assert_match /my_alias.*/, ha.name
    assert_match /host.*/, ha.cname
    assert_match /example.*\.com/, ha.domain.to_s
    assert_match /eth.*/, ha.nic.identifier
  end

  test '#host_alias should be unique in the context of a domain' do
    domain = FactoryGirl.create(:domain)
    FactoryGirl.create(:host_alias, :name => 'my_alias', :domain => domain)

    assert_raise ActiveRecord::RecordInvalid do
      FactoryGirl.create(:host_alias, :name => 'my_alias', :domain => domain)
    end
  end

  test 'same #nic should has many host_aliases' do
    ha1 = FactoryGirl.create(:host_alias, :name => 'my_alias')
    FactoryGirl.create(:host_alias, :name => 'my_2nd_alias',
                       :nic => ha1.nic,
                       :domain => ha1.domain)
    assert_equal 2, ha1.nic.host_aliases.size
  end

  test '#nic should have host_aliases in distincts domains' do
    ha1 = FactoryGirl.create(:host_alias)
    nic = ha1.nic
    ha2 = FactoryGirl.create(:host_alias,
                            :nic => nic,
                            :domain => FactoryGirl.create(:domain))

    refute_equal nic.host_aliases[0].domain,
                 nic.host_aliases[1].domain
  end

  test '#host_alias should point to full CNAME' do
    ha = FactoryGirl.build(:host_alias,
                           :nic => FactoryGirl.create(:nic_base,
                                                      :host => FactoryGirl.create(:host,
                                                                                  :managed)))
    assert_match /host.*\.example.*\.com/, ha.cname
  end
end
