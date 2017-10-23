require 'test_helper'

class DummyComputeResource < ComputeResource
  include KeyPairComputeResource
  include Mocha::API

  def client
    @client ||= mock('client')
  end
end

class KeyPairComputeResourceTest < ActiveSupport::TestCase
  # We can't use 'Fog::Compute::AWS::KeyPair' model
  # This class mocks it.
  class FakeKeyPair
    attr_reader :name, :fingerprint, :private_key

    def initialize(name, fingerprint, private_key = nil)
      @name = name
      @fingerprint = fingerprint
      @private_key = private_key
    end
  end

  test "#get_compute_key_pairs" do
    @key_pairs = []
    3.times do |i|
      @key_pairs << FakeKeyPair.new("foreman-#{i}", "13:01:73:0#{i}")
    end

    cr = DummyComputeResource.new
    key_pair = FactoryBot.build(:key_pair)
    cr.key_pair = key_pair
    DummyComputeResource.any_instance.stubs(:key_pairs).returns(@key_pairs)
    assert_kind_of(ComputeResourceKeyPair, cr.get_compute_key_pairs.first)
  end

  test 'should remove the key pair on compute resource deletion' do
    cr = DummyComputeResource.new
    key_pair = FactoryBot.build(:key_pair)
    cr.key_pair = key_pair
    mock_key_pairs = mock('mock_key_pairs')
    fog_key_pair = mock('fog_key_pair')
    cr.send(:client).expects(:key_pairs).returns(mock_key_pairs)
    mock_key_pairs.expects(:get).with(key_pair.name).returns(fog_key_pair)
    key_pair.expects(:destroy).once
    fog_key_pair.expects(:destroy).once
    assert cr.destroy!
  end
end
