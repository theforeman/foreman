require 'test_helper'

class EncOutputTest < ActiveSupport::TestCase
  class SampleModel
    attr_accessor :name, :attrs, :subnet, :mac, :password, :subnet
    include EncOutput
    register_to_enc_transformation :mac, lambda { |v| v.upcase }

    def attributes
      {
        'name' => name,
        'attrs' => attrs,
        'mac' => mac,
        'password' => password,
        'subnet' => subnet
      }
    end

    def enc_attributes
      %w(name attrs mac)
    end

    def embed_associations
      %w(subnet)
    end
  end

  class SampleSubnet
    attr_accessor :name, :network
    include EncOutput

    def attributes
      {
        'name' => name,
        'network' => network
      }
    end

    private

    def enc_attributes
      %w(name network)
    end
  end

  def setup
    @subnet = SampleSubnet.new
    @subnet.name = 'pxe'
    @subnet.network = '192.168.122.0'

    @sample = SampleModel.new
    @sample.name = 'name'
    @sample.attrs = {'nested' => 'hash'}
    @sample.subnet = @subnet
    @sample.mac = 'aa:bb:cc:dd:ee:ff'
    @sample.password = 'password'
  end

  test '#to_enc includes all specified attributes' do
    assert_equal %w(name attrs mac subnet), @sample.to_enc.keys
  end

  test '#to_enc does not include all attributes' do
    assert_not_includes @sample.to_enc.keys, 'password'
  end

  test '#to_enc values are dumped recursively with embed associations and transformations are applied' do
    enc = @sample.to_enc
    assert_equal('name', enc['name'])
    assert_equal({'nested' => 'hash'}, enc['attrs'])
    assert_equal('AA:BB:CC:DD:EE:FF', enc['mac'])
    assert_equal('pxe', enc['subnet']['name'])
    assert_equal('192.168.122.0', enc['subnet']['network'])
  end

  test '#to_enc embed associations works if associations is not set' do
    @sample.subnet = nil
    enc = @sample.to_enc
    assert_nil(enc['subnet'])
  end

  test '#to_enc converts hash with indifferent access to normal hash' do
    @sample.attrs = {}.with_indifferent_access
    enc = @sample.to_enc
    assert_instance_of Hash, enc['attrs']
  end
end
