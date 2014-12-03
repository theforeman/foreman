require 'test_helper'

class MailNotificationTest < ActiveSupport::TestCase

  test "can find notification as hash key" do
    mailer = FactoryGirl.create(:mail_notification)
    assert_equal MailNotification[mailer.name], mailer
  end

  test "user with mail disabled doesn't get mail" do
    Setting[:send_welcome_email] = true
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      User.create :auth_source => auth_sources(:internal), :login => "welcome", :mail  => "foo@bar.com", :password => "qux", :mail_enabled => false
    end
  end
end
