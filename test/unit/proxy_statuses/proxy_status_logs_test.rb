require 'test_helper'

class ProxyStatusLogsTest < ActiveSupport::TestCase
  setup do
    @empty_buffer = {
      "info" => {
        "failed_modules" => {},
      },
      "logs" => []}

    @four_entries_buffer = {
      "info" => {
        "failed_modules" => {},
      },
      "logs" => [
        { "timestamp" => 1000, "level" => "INFO", "message" => "Message" },
        { "timestamp" => 1001, "level" => "INFO", "message" => "Message" },
        { "timestamp" => 1002, "level" => "ERROR", "message" => "Message" },
        { "timestamp" => 1003, "level" => "FATAL", "message" => "Message" },
      ]}

    @two_failed_buffer = {
      "info" => {
        "failed_modules" => {
          "BMC" => "Message",
          "Puppet" => "Another message",
        },
      },
      "logs" => []}

    @proxy = FactoryBot.build_stubbed(:smart_proxy, :url => 'https://secure.proxy:4568')
    @status = ProxyStatus::Logs.new(@proxy, :cache => false)
  end

  test 'it returns an empty buffer' do
    ProxyAPI::Logs.any_instance.expects(:all).returns(@empty_buffer)
    assert_equal([], @status.logs.log_entries)
  end

  test 'it aggregates data' do
    ProxyAPI::Logs.any_instance.expects(:all).returns(@four_entries_buffer)
    aggregates = @status.logs.aggregated_logs
    assert_equal(2, aggregates['info'])
    assert_equal(1, aggregates['error'])
    assert_equal(1, aggregates['fatal'])
    assert_equal(0, aggregates['debug'])
  end

  test 'it aggregates data' do
    ProxyAPI::Logs.any_instance.expects(:all).returns(@four_entries_buffer)
    logs = @status.logs
    assert_equal(2, logs.info_messages)
    assert_equal(2, logs.error_or_fatal_messages)
    assert_equal(0, logs.warn_messages)
    assert_equal(1, logs.fatal_messages)
  end

  test 'it returns failed module names' do
    ProxyAPI::Logs.any_instance.expects(:all).returns(@two_failed_buffer)
    assert_equal(["BMC", "Puppet"], @status.logs.failed_module_names)
  end

  test 'it returns failed modules' do
    ProxyAPI::Logs.any_instance.expects(:all).returns(@two_failed_buffer)
    modules = @status.logs.failed_modules
    assert_equal("Message", modules['BMC'])
    assert_equal("Another message", modules['Puppet'])
    assert_equal(2, modules.count)
  end
end
