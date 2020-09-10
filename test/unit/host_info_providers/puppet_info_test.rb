require 'test_helper'

module HostInfoProviders
  class PuppetInfoTest < ActiveSupport::TestCase
    let(:host_params) do
      {
        location:      taxonomies(:location1),
        organization:  taxonomies(:organization1),
        puppetclasses: [puppetclasses(:one)],
        environment:   environments(:production),
      }
    end
    let(:host1) { FactoryBot.create(:host, host_params) }
    let(:host2) { FactoryBot.create(:host, host_params) }
    let(:host3) { FactoryBot.create(:host, host_params) }

    test 'fetching correct value to a given key' do
      key = ""
      value = ""
      puppetclass = puppetclasses(:one)

      as_admin do
        key = PuppetclassLookupKey.create!(:key => "dns", :path => "domain\npuppetversion", :override => true)
        value = LookupValue.create!(:value => "[1.2.3.4,2.3.4.5]", :match => "domain =  mydomain.net", :lookup_key => key)
        EnvironmentClass.create!(:puppetclass => puppetclass, :environment => environments(:production),
                                 :puppetclass_lookup_key => key)
      end

      key.reload
      assert key.lookup_values.count > 0
      host1.domain = domains(:mydomain)

      assert_equal value.value, HostInfoProviders::PuppetInfo.new(host1).puppetclass_parameters['base']['dns']
    end

    test 'multiple paths' do
      host1.hostgroup = hostgroups(:common)
      host1.environment = environments(:testing)

      host2.hostgroup = hostgroups(:unusual)
      host2.environment = environments(:testing)

      host3.environment = environments(:testing)

      default = "default"
      puppetclass = Puppetclass.first
      key = PuppetclassLookupKey.create!(:key => "dns", :path => "environment,hostgroup\nhostgroup\nfqdn", :default_value => default, :override => true)
      value1 = LookupValue.create!(:value => "v1", :match => "environment=testing,hostgroup=Common", :lookup_key => key)
      value2 = LookupValue.create!(:value => "v2", :match => "hostgroup=Unusual", :lookup_key => key)

      LookupValue.create!(:value => "v22", :match => "fqdn=#{host2.fqdn}", :lookup_key => key)
      EnvironmentClass.create!(:puppetclass => puppetclass, :environment => environments(:testing),
                               :puppetclass_lookup_key => key)
      HostClass.create!(:host => host1, :puppetclass => puppetclass)
      HostClass.create!(:host => host2, :puppetclass => puppetclass)
      HostClass.create!(:host => host3, :puppetclass => puppetclass)

      key.reload

      assert_equal value1.value, HostInfoProviders::PuppetInfo.new(host1).puppetclass_parameters['apache']['dns']
      assert_equal value2.value, HostInfoProviders::PuppetInfo.new(host2).puppetclass_parameters['apache']['dns']
      assert_equal default, HostInfoProviders::PuppetInfo.new(host3).puppetclass_parameters['apache']['dns']
      assert key.overridden?(host2)
      refute key.overridden?(host1)
    end
  end
end
