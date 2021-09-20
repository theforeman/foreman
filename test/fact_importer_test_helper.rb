# Create notification blueprints prior to tests
module FactImporterIsolation
  extend ActiveSupport::Concern

  def allow_transactions_for(importer)
    importer.stubs(:ensure_no_active_transaction).returns(true)
  end

  def allow_transactions_for_any_importer
    [FactImporters::Base, FactImporters::Structured].each do |importer|
      allow_transactions_for(importer.any_instance)
    end
  end

  module ClassMethods
    def allow_transactions_for_any_importer
      setup :allow_transactions_for_any_importer
    end
  end
end

module FactsData
  class FlatFacts
    def filter
      ['ignore*', '*_bad', 'filter']
    end

    def good_facts
      {
        'just_a_fact' => 'hello',
        'nofilter' => 'hello',
      }
    end

    def ignored_facts
      {
        'ignored_fact' => 'will_not_show',
        'fact_bad' => 'will_not_show',
        'filter' => 'will_not_show',
        'ignore' => 'will_not_show',
        '_bad' => 'will_not_show',
      }
    end
  end

  class RhsmStyleFacts
    def filter
      ['ignore*', '*_bad', 'filter']
    end

    def good_facts
      {
        'something::something_else' => 'hello',
      }
    end

    def ignored_facts
      {
        'ignored_fact::something' => 'will_not_show',
        'something::ignored_fact' => 'will_not_show',
        'something::ignored_fact::something_else' => 'will_not_show',
        'fact_bad::something' => 'will_not_show',
        'something::fact_bad' => 'will_not_show',
        'something::fact_bad::something_else' => 'will_not_show',
        'filter::something' => 'will_not_show',
        'something::filter' => 'will_not_show',
        'something::filter::something_else' => 'will_not_show',
      }
    end
  end

  class FlatPuppetStyleFacts
    def filter
      ['ignore*', '*_bad', 'filter']
    end

    def good_facts
      {
        'something_filter_something_else' => 'hello',
        'filter_something' => 'hello',
      }
    end

    def ignored_facts
      {
        'ignored_fact_something' => 'will_not_show',
        'something_fact_bad' => 'will_not_show',
        'filter' => 'will_not_show',
        'mtu_filter' => 'will_not_show',
        'facter_mtu_filter' => 'will_not_show',
        'ipaddress_filter' => 'will_not_show',
        'ipaddress6_filter' => 'will_not_show',
        'facter_ipaddress6_filter' => 'will_not_show',
      }
    end
  end

  class HierarchicalPuppetStyleFacts
    def filter
      ['ignored*']
    end

    def good_facts
      {
        :good => 'hello',
        :common_ancestor => {
          :good_subtree => {
            :good_key => 'hello',
          },
        },
      }
    end

    def ignored_facts
      {
        :common_ancestor => {
          :ignored_subtree => {
            :key1 => 'will_not_show',
            :key2 => 'will_not_show',
          },
        },
        :empty_ancestor => {
          :ignored_key => 'will_not_show',
        },
        :ignored_value => 'will_not_show',
      }
    end

    def flat_result
      {
        "good" => "hello",
        "common_ancestor::good_subtree::good_key" => "hello",
        "common_ancestor::good_subtree" => nil,
        "common_ancestor" => nil,
      }
    end
  end

  class DefaultInterfacesFacts
    def filter
      Setting[:excluded_facts]
    end

    def good_facts
      {
        'macaddress_virbr4' => 'fe:54:00:59:4e:bf',
        'mtu_virbr4' => '1500',
        'non_docker_host' => 'non_docker_host',
        'net::interface::virbr4::ipv6_address::link' => 'fe80::fc54:ff:fe59:4ebf',
        'net::interface::virbr4::ipv6_address::link_list' => 'fe80::fc54:ff:fe59:4ebf',
        'net::interface::virbr4::ipv6_netmask::link' => '64',
        'net::interface::virbr4::ipv6_netmask::link_list' => '64',
        'net::interface::virbr4::mac_address' => 'FE:54:00:59:4E:BF',
        'net::interface::virbr4::permanent_mac_address' => 'Unknown',
      }
    end

    def ignored_facts
      {
        'macaddress_vnet4' => 'fe:54:00:59:4e:bf',
        'mtu_vnet4' => '1500',
        'docker_host' => 'ignored_host',
        'net::interface::vnet4::ipv6_address::link' => 'fe80::fc54:ff:fe59:4ebf',
        'net::interface::macvtap1::ipv6_address::link_list' => 'fe80::fc54:ff:fe59:4ebf',
        'net::interface::veth4::ipv6_netmask::link' => '64',
        'net::interface::docker4::ipv6_netmask::link_list' => '64',
        'net::interface::vlinuxbr4::mac_address' => 'FE:54:00:59:4E:BF',
        'net::interface::usb4::permanent_mac_address' => 'Unknown',
        'load_averages::5m' => '0.01',
        'load_averages::10m' => '0.02',
        'load_averages::15m' => '0.03',
        'memory::system::capacity' => '0%',
        'memory::system::used' => '0 bytes',
        'memory::system::used_bytes' => '0',
        'memory::system::available' => '1.00 GiB',
        'memory::system::available_bytes' => '1073737728',
        'memory::swap::capacity' => '0%',
        'memory::swap::used' => '0 bytes',
        'memory::swap::used_bytes' => '0',
        'memory::swap::available' => '1.00 GiB',
        'memory::swap::available_bytes' => '1073737728',
      }
    end
  end
end
