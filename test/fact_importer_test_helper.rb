# Create notification blueprints prior to tests
module FactImporterIsolation
  extend ActiveSupport::Concern

  def allow_transactions_for(importer)
    importer.stubs(:ensure_no_active_transaction).returns(true)
  end

  module ClassMethods
    def allow_transactions_for_any_importer
      FactImporter.singleton_class.prepend FactImporterFactoryStubber

      FactImporter.register_instance_stubs do |importer_class|
        importer_class.any_instance.stubs(:ensure_no_active_transaction).returns(true)
      end
    end
  end
end

module FactImporterFactoryStubber
  def register_instance_stubs(&block)
    instance_stubs << block
  end

  def importer_for(*args)
    instance = super
    instance_stubs.each do |stub_block|
      stub_block.call(instance)
    end
    instance
  end

  def instance_stubs
    @instance_stubs ||= []
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
        'nofilter' => 'hello'
      }
    end

    def ignored_facts
      {
        'ignored_fact' => 'will_not_show',
        'fact_bad' => 'will_not_show',
        'filter' => 'will_not_show',
        'ignore' => 'will_not_show',
        '_bad' => 'will_not_show'
      }
    end
  end

  class RhsmStyleFacts
    def filter
      ['ignore*', '*_bad', 'filter']
    end

    def good_facts
      {
        'something::something_else' => 'hello'
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
        'something::filter::something_else' => 'will_not_show'
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
        'fact_bad_something' => 'hello',
        'filter_something' => 'hello'
      }
    end

    def ignored_facts
      {
        'ignored_fact_something' => 'will_not_show',
        'something_ignored_fact' => 'will_not_show',
        'something_ignored_fact_something_else' => 'will_not_show',
        'something_fact_bad' => 'will_not_show',
        'something_filter' => 'will_not_show'
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
            :good_key => 'hello'
          }
        }
      }
    end

    def ignored_facts
      {
        :common_ancestor => {
          :ignored_subtree => {
            :key1 => 'will_not_show',
            :key2 => 'will_not_show'
          }
        },
        :empty_ancestor => {
          :ignored_key => 'will_not_show'
        },
        :ignored_value => 'will_not_show'
      }
    end

    def flat_result
      {
        "good" => "hello",
        "common_ancestor::good_subtree::good_key" => "hello",
        "common_ancestor::good_subtree" => nil,
        "common_ancestor" => nil
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
        'net::interface::virbr4::ipv6_address::link' => 'fe80::fc54:ff:fe59:4ebf',
        'net::interface::virbr4::ipv6_address::link_list' => 'fe80::fc54:ff:fe59:4ebf',
        'net::interface::virbr4::ipv6_netmask::link' => '64',
        'net::interface::virbr4::ipv6_netmask::link_list' => '64',
        'net::interface::virbr4::mac_address' => 'FE:54:00:59:4E:BF',
        'net::interface::virbr4::permanent_mac_address' => 'Unknown'
      }
    end

    def ignored_facts
      {
        'macaddress_vnet4' => 'fe:54:00:59:4e:bf',
        'mtu_vnet4' => '1500',
        'net::interface::vnet4::ipv6_address::link' => 'fe80::fc54:ff:fe59:4ebf',
        'net::interface::macvtap1::ipv6_address::link_list' => 'fe80::fc54:ff:fe59:4ebf',
        'net::interface::veth4::ipv6_netmask::link' => '64',
        'net::interface::docker4::ipv6_netmask::link_list' => '64',
        'net::interface::vlinuxbr4::mac_address' => 'FE:54:00:59:4E:BF',
        'net::interface::usb4::permanent_mac_address' => 'Unknown'
      }
    end
  end

  class DefaultDisksFacts
    def filter
      Setting[:excluded_facts]
    end

    def good_facts
      {
        'good_fact' => 'a_value'
      }
    end

    def ignored_facts
      {
        'partitions' => {"nvme0n1p5" => {}, "nvme0n1p3" => {"uuid" => "2bff39f0-8e86-4852-9ef5-a27d2d64064f", "mount" => "/"}},
        'mountpoints' => {"/var/lib/kubelet/pods/18d36b62-526f-11e9-98b1-0200004190da/volumes/kubernetes.io~secret/certs" => {"used_bytes" => 13}}
      }
    end
  end
end
