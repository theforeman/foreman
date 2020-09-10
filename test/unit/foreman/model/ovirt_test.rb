require 'test_helper'

class OvirtTest < ActiveSupport::TestCase
  def setup
    User.current = users(:admin)
  end

  def new_ovirt_cr(proto = 'http')
    ComputeResource.new_provider(
      :provider => "Ovirt",
      :name => :myovirt,
      :user => 'user',
      :password => 'password',
      :public_key => 'ovirtcacert',
      :url => "#{proto}://ovirt.example.com/"
    )
  end

  test "create a new oVirt compute resource" do
    record = new_ovirt_cr
    assert record.valid?
  end

  test "fingerprint error is ignored on update of operating systems" do
    record = new_ovirt_cr
    record.stubs(:client).raises(Foreman::FingerprintException.new('fingerprint error'))
    original_oses = record.attrs[:available_operating_systems] = { foo: :bar }

    assert_nothing_raised do
      assert record.send(:update_available_operating_systems), 'after validation filter does not return true which would cancel the callback chain'
    end

    assert_equal original_oses, record.attrs[:available_operating_systems]

    record.url = ''
    refute record.valid?

    assert_nothing_raised do
      refute record.send(:update_available_operating_systems), 'after validation filter does not return false which would not cancel the callback chain'
    end

    assert_equal original_oses, record.attrs[:available_operating_systems]
  end

  test "#supports_operating_systems? defaults to false if there's SSL issue" do
    record = new_ovirt_cr
    record.stubs(:client).raises(Foreman::FingerprintException.new('fingerprint error'))

    assert_nothing_raised do
      refute record.supports_operating_systems?, 'Foreman::Model::Ovirt#supports_operating_systems? returns true even if there is SSL issue'
    end
  end

  test "test_connection should fail if datacenters not found (404)" do
    client = stub()
    client.stubs(:datacenters).raises(StandardError.new('404 error'))
    record = new_ovirt_cr
    record.stubs(:client).returns(client)
    record.test_connection
    assert_equal ['404 error'], record.errors[:url]
    assert_equal [], record.errors[:base]
  end

  test "test_connection should fail if not authorized for datacenters (401)" do
    client = stub()
    client.stubs(:datacenters).raises(StandardError.new('401 error'))
    record = new_ovirt_cr
    record.stubs(:client).returns(client)
    record.test_connection
    assert_equal ['401 error'], record.errors[:user]
    assert_equal [], record.errors[:base]
  end

  test "test_connection should succeed with HTTP url" do
    record = new_ovirt_cr 'http'
    record.expects(:client).never()
    record.stubs(:datacenters).returns(['example', 1])
    # returned by oVirt when HTTP is valid and we POST to /api
    RestClient.expects(:post).raises(StandardError.new('406 Not Acceptable'))
    assert record.test_connection
    assert_equal [], record.errors[:base]
  end

  test "test_connection should succeed with HTTPS url" do
    record = new_ovirt_cr 'https'
    record.expects(:client).never()
    record.stubs(:datacenters).returns(['example', 1])
    RestClient.expects(:post).never()
    assert record.test_connection
    assert record.errors.empty?
  end

  test "test_connection should detect 302 HTTPS redirect with HTTP url and fail" do
    record = new_ovirt_cr 'http'
    record.expects(:client).never()
    record.stubs(:datacenters).returns(['example', 1])
    # RestClient throws 302 as an error during POSTs
    RestClient.expects(:post).raises(StandardError.new('302 Found'))
    record.test_connection
    assert_match /HTTPS/, record.errors[:url].first
    assert_equal [], record.errors[:base]
  end
end
