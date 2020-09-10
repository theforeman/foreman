require 'test_helper'

class ExportableTest < ActiveSupport::TestCase
  class SampleModel
    include Exportable

    attr_accessor :name, :attrs, :subnet, :mac, :password, :subnet
    attr_exportable :name, :attrs, :mac, :subnet, :mac => ->(m) { m.mac.upcase if m.mac },
      :custom_attr => ->(m) { "hello world" }

    def attributes
      {
        'name' => name,
        'attrs' => attrs,
        'mac' => mac,
        'password' => password,
        'subnet' => subnet,
      }
    end
  end

  class SampleSubnet
    include Exportable

    attr_accessor :name, :network
    attr_exportable :name, :network

    def attributes
      {
        'name' => name,
        'network' => network,
      }
    end
  end

  class SampleSubnet::WithDomain < SampleSubnet
    include Exportable

    attr_accessor :domain
    attr_exportable :domain

    def attributes
      {
        'name' => name,
        'network' => network,
        'domain' => domain,
      }
    end
  end

  def setup
    @subnet = SampleSubnet.new
    @subnet.name = 'pxe'
    @subnet.network = '192.168.122.0'

    @subnet_domain = SampleSubnet::WithDomain.new
    @subnet_domain.name = 'dmz'
    @subnet_domain.network = '192.168.122.0'
    @subnet_domain.domain = 'example.com'

    @sample = SampleModel.new
    @sample.name = 'name'
    @sample.attrs = {'nested' => 'hash'}
    @sample.subnet = @subnet
    @sample.mac = 'aa:bb:cc:dd:ee:ff'
    @sample.password = 'password'
  end

  test '#to_export includes all specified attributes' do
    assert_equal %w(name attrs mac subnet custom_attr), @sample.to_export.keys
  end

  test '#to_export does not include all attributes' do
    assert_not_include @sample.to_export.keys, 'password'
  end

  test "#to_export calls the lambda" do
    export = @sample.to_export
    assert_equal('AA:BB:CC:DD:EE:FF', export['mac'])
    assert_equal(export['custom_attr'], "hello world")
  end

  test '#to_export values are exported recursively' do
    export = @sample.to_export
    assert_equal('pxe', export['subnet']['name'])
    assert_equal('192.168.122.0', export['subnet']['network'])
  end

  test '#to_export nested hashes are primitive' do
    @sample.attrs = {:foo => 'bar', :baz => 'qux'}.with_indifferent_access
    export = @sample.to_export
    assert_instance_of Hash, export['attrs']
  end

  test '#to_export includes blank values' do
    @sample.attrs = {}
    export = @sample.to_export
    assert_instance_of Hash, export['attrs']
  end

  test '#to_export(false) does not include blank values' do
    @sample.attrs = {}
    export = @sample.to_export(false)
    assert_nil export['attrs']
  end

  test '#exportable_attributes includes parent class attrs' do
    assert_empty SampleSubnet.exportable_attributes.keys - SampleSubnet::WithDomain.exportable_attributes.keys
  end

  test '#to_export includes parent class exportables' do
    assert_empty SampleSubnet.exportable_attributes.stringify_keys.keys - @subnet_domain.to_export.keys
  end

  test '#exportable_attributes does not include child class attrs' do
    refute SampleSubnet.exportable_attributes.key?('domain')
  end

  test '#to_export includes own class exportables' do
    assert @subnet_domain.to_export.key?('domain')
  end
end
