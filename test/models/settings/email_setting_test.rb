require 'test_helper'

class EmailSettingTest < ActiveSupport::TestCase
  context "when email.yaml exists" do
    setup do
      @delivery_settings = {"delivery_method" => :smtp,
                           "smtp_settings" =>
                             {"address" => "smtp.example",
                             "authentication"=>"plain"},
                           "sendmail_settings" =>
                             {"arguments" => "args1"}}

      Setting::Email.stubs(:mailconfig).returns(@delivery_settings)
    end

    test 'should use smtp settings' do
      load_defaults
      assert_equal(@delivery_settings["smtp_settings"], Setting::Email.delivery_settings)
    end

    test 'should use sendmail settings' do
      @delivery_settings["delivery_method"] = :sendmail
      load_defaults
      assert_equal(@delivery_settings["sendmail_settings"], Setting::Email.delivery_settings)
    end

    test 'email setting should be read only if email.yaml exsits' do
      assert_raise ActiveRecord::ReadOnlyRecord do
        Setting[:smtp_address] = "sm@example.com"
      end
    end

    test 'email setting should be editable if it not exist in NON_EMAIL_YAML_SETTINGS list' do
      Setting[:email_reply_address] = "example@example.com"
      assert_equal("example@example.com", Setting[:email_reply_address])
    end

    test 'delivery_method setting value can be a string' do
      @delivery_settings["delivery_method"] = 'smtp'
      load_defaults
      assert_equal(@delivery_settings["smtp_settings"], Setting::Email.delivery_settings)
    end
  end

  context "when email.yaml does not exist" do
    setup do
      Setting::Email.stubs(:mailconfig).returns({})
    end

    test 'email settings should be editable if email.yaml not exist' do
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
  end

  private

  def load_defaults
    Setting::Email.transaction do
      [
        Setting::Email.set('delivery_method', N_("Method used to deliver email"), 'test', nil, nil, { :collection => Proc.new {{'Sendmail' => :sendmail, 'SMTP' => :smtp}}}),
        Setting::Email.set('smtp_address', N_("Address to connect to"), '', nil),
        Setting::Email.set('smtp_authentication', N_("Specify authentication type, if required"), 'none', nil, nil, { :collection => Proc.new {{'plain' => :plain, 'login' => :login, 'cram_md5' => :cram_md5, 'none' => :none}}}),
        Setting::Email.set('sendmail_arguments', N_("Specify additional options to sendmail"), '-i', nil)
      ].each { |s| Setting::Email.create! s.update(:category => "Setting::Email")}
    end
  end
end
