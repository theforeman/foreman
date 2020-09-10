require 'test_helper'

class DummyComputeResource < ComputeResource
  include KeyPairComputeResource
  include Mocha::API

  def client
    @client ||= ::Fog::Compute.new(
      provider: :aws,
      aws_access_key_id: 'foo',
      aws_secret_access_key: 'bar'
    )
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
    key_pair = FactoryBot.build_stubbed(:key_pair)
    cr.key_pair = key_pair
    DummyComputeResource.any_instance.stubs(:key_pairs).returns(@key_pairs)
    assert_kind_of(ComputeResourceKeyPair, cr.get_compute_key_pairs.first)
  end

  test 'should remove the key pair on compute resource deletion' do
    Fog.mock!
    key_pair = FactoryBot.create(:key_pair)
    cr = DummyComputeResource.create(name: Foreman.uuid, provider: 'EC2')
    # we must use the update key in order to make the test work, or we shell
    # have an exception that the data was unable to be destroyed
    cr.update_attribute(:key_pair, key_pair)
    Fog.unmock!
    assert cr.destroy!
  end
end
