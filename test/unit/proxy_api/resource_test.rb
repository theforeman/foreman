require 'test_helper'

class ProxyApiResourceTest < ActiveSupport::TestCase
  setup do
    ProxyAPI::Resource.any_instance.stubs(:url).returns('http://proxy.example.com')
  end

  test "connect_params includes x_request_id header" do
    assert ProxyAPI::Resource.new({}).send(:connect_params)[:headers][:x_request_id].present?
  end

  test "connect_params sets x_request_id to logger request ID" do
    ::Logging.mdc['request'] = '850ca7f1-c6de-481f-86a9-dc379a04b445'
    assert_equal '850ca7f1-c6de-481f-86a9-dc379a04b445', ProxyAPI::Resource.new({}).send(:connect_params)[:headers][:x_request_id]
  ensure
    ::Logging.mdc.delete('request')
  end

  test "connect_params sets x_request_id to logger safe session ID" do
    ::Logging.mdc['session'] = '850ca7f1-c6de-481f-86a9-dc379a04b446'
    assert_equal '850ca7f1-c6de-481f-86a9-dc379a04b446', ProxyAPI::Resource.new({}).send(:connect_params)[:headers][:x_session_id]
  ensure
    ::Logging.mdc.delete('session')
  end

  test "with_logger sets RestClient.log" do
    refute RestClient.log
    ProxyAPI::Resource.new({}).send(:with_logger) do
      assert_respond_to RestClient.log, :<<
    end
    refute RestClient.log
  end

  test "RestClientLogger#<< logs messages" do
    logger = mock('logger')
    logger.expects(:debug).with('test')
    ProxyAPI::RestClientLogger.new(logger) << "test\n"
  end
end
