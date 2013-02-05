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
      :url => "#{proto}://ovirt.example.com/"
    )
  end

  test "create a new oVirt compute resource" do
    record = new_ovirt_cr
    assert record.valid?
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
