require 'test_helper'

class HostPresenterTest < ActiveSupport::TestCase
  let(:host) { Host.new(:name => "test.example.com") }

  test "display_name when :display_fqdn_for_hosts is true" do
    Setting[:display_fqdn_for_hosts] = true
    assert_equal "test.example.com", HostPresenter.display_name("test.example.com")
  end

  test "display_name when :display_fqdn_for_hosts is false" do
    Setting[:display_fqdn_for_hosts] = false
    assert_equal "test", HostPresenter.display_name("test.example.com")
  end

  test "host.to_label when :display_fqdn_for_hosts is true" do
    Setting[:display_fqdn_for_hosts] = true
    assert_equal "test.example.com", host.to_label
  end

  test "host.to_label when :display_fqdn_for_hosts is false" do
    Setting[:display_fqdn_for_hosts] = false
    assert_equal "test", host.to_label
  end
end
