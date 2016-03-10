require 'test_helper'

class MailNotificationTest < ActiveSupport::TestCase
  test "can find notification as hash key" do
    mailer = FactoryGirl.create(:mail_notification)
    assert_equal MailNotification[mailer.name], mailer
  end

  test "user with mail disabled doesn't get mail" do
    user = FactoryGirl.create(:user, :with_mail, :mail_enabled => false)
    user.mail_notifications << MailNotification[:puppet_summary]
    notification = user.user_mail_notifications.find_by_mail_notification_id(MailNotification[:puppet_summary])

    assert_no_difference "ActionMailer::Base.deliveries.size" do
      notification.deliver
    end
  end

  test "#deliver generates mails for each user in :users option" do
    users = FactoryGirl.create_pair(:user, :with_mail)
    mailer = FactoryGirl.create(:mail_notification)
    mail = mock('mail')
    mail.expects(:deliver).twice
    HostMailer.expects(:test_mail).with(:foo, :user => users[0]).returns(mail)
    HostMailer.expects(:test_mail).with(:foo, :user => users[1]).returns(mail)
    mailer.deliver(:foo, :users => users)
  end

  test "when a notification with 'puppet_error_state' name generated, a subclass PuppeError should created" do
    mailer =  FactoryGirl.build(:mail_notification, :puppet_error)
    assert mailer.type == 'PuppetError'
  end
end
