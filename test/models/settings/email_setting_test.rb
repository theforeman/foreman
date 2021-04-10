require 'test_helper'

class EmailSettingTest < ActiveSupport::TestCase
  test 'delivery_settings return values set by Setting#[]=' do
    Setting[:delivery_method] = :smtp
    Setting[:smtp_address] = "sm@example.com"
    Setting[:smtp_authentication] = "plain"
    assert_equal({"address" => "sm@example.com", "authentication" => "plain", "enable_starttls_auto" => true, "port" => 25}, Setting::Email.delivery_settings)
  end

  test 'setting should be clear from delivery settings when it empty' do
    Setting[:delivery_method] = :smtp
    Setting[:smtp_address] = "sm@example.com"
    Setting[:smtp_authentication] = ''
    assert_equal({"address" => "sm@example.com", "enable_starttls_auto" => true, "port" => 25}, Setting::Email.delivery_settings)
  end

  test 'delivery_method setting value can be a string' do
    Setting[:delivery_method] = 'smtp'
    Setting[:smtp_address] = "string@example.com"
    Setting[:smtp_authentication] = 'plain'
    assert_equal({"address" => "string@example.com", "authentication" => 'plain', "enable_starttls_auto" => true, "port" => 25}, Setting::Email.delivery_settings)
  end

  test 'value of email_subject_prefix should not be more than 255 characters' do
    assert_raises(ActiveRecord::RecordInvalid) { Setting[:email_subject_prefix] = 'p' * 256 }
  end
end
