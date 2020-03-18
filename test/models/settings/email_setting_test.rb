require 'test_helper'

class EmailSettingTest < ActiveSupport::TestCase
  test 'delivery_settings return values set by Setting#[]=' do
    Setting[:delivery_method] = :smtp
    Setting[:smtp_address] = "sm@example.com"
    Setting[:smtp_authentication] = "plain"
    assert_equal({"address" => "sm@example.com", "authentication" => "plain"}, Setting::Email.delivery_settings)
  end

  test 'setting should be clear from delivery settings when it empty' do
    Setting[:delivery_method] = :smtp
    Setting[:smtp_address] = "sm@example.com"
    Setting[:smtp_authentication] = ''
    assert_equal({"address" => "sm@example.com"}, Setting::Email.delivery_settings)
  end

  test 'delivery_method setting value can be a string' do
    Setting[:delivery_method] = 'smtp'
    Setting[:smtp_address] = "string@example.com"
    Setting[:smtp_authentication] = 'plain'
    assert_equal({"address" => "string@example.com", "authentication" => 'plain'}, Setting::Email.delivery_settings)
  end

  test 'value of email_subject_prefix should not be more than 255 characters' do
    assert_raises(ActiveRecord::RecordInvalid) { Setting[:email_subject_prefix] = 'p' * 256 }
  end

  private

  def load_defaults
    Setting::Email.transaction do
      [
        Setting::Email.set('delivery_method', N_("Method used to deliver email"), 'test', nil, nil, { :collection => proc { {'Sendmail' => :sendmail, 'SMTP' => :smtp} }}),
        Setting::Email.set('smtp_address', N_("Address to connect to"), '', nil),
        Setting::Email.set('smtp_authentication', N_("Specify authentication type, if required"), 'none', nil, nil, { :collection => proc { {'plain' => :plain, 'login' => :login, 'cram_md5' => :cram_md5, 'none' => :none} }}),
        Setting::Email.set('sendmail_arguments', N_("Specify additional options to sendmail"), '-i', nil),
      ].each { |s| Setting::Email.create! s.update(:category => "Setting::Email") }
    end
  end
end
