require 'test_helper'

class KeyPairTest < ActiveSupport::TestCase
  should belong_to(:compute_resource)

  test "ensure validations" do
    key = KeyPair.new
    refute key.valid?
    assert_equal([:name, :secret, :compute_resource_id], key.errors.messages.keys)
    assert_equal(["can't be blank"], key.errors.messages.values.first.compact)
  end

  context "compute resource key pair" do
    setup do
      @compute_resource = FactoryBot.create(:ec2_cr)
      @key_pair = FactoryBot.create(:key_pair, compute_resource: @compute_resource)
    end

    test "should not be active" do
      key = ComputeResourceKeyPair.new('heisneberg', '13:01:73:00:15', @key_pair.name, @key_pair.id)
      refute key.active
      assert_nil key.key_pair_id
    end

    test "should be active" do
      key = ComputeResourceKeyPair.new(@key_pair.name, '03:07:74:19:00', @key_pair.name, @key_pair.id)
      assert key.active
      refute_nil key.key_pair_id
    end

    test "should be used elsewhere" do
      another_key_pair = FactoryBot.create(:key_pair)
      key = ComputeResourceKeyPair.new(another_key_pair.name, '30:06:44:08:30', @key_pair.name, @key_pair.id)
      refute key.active
      assert key.used_elsewhere
    end

    test "should not be used elsewhere" do
      key = ComputeResourceKeyPair.new('some-key', '04:12:07:17:45', @key_pair.name, @key_pair.id)
      refute key.active
      refute key.used_elsewhere
    end
  end
end
