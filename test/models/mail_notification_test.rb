require 'test_helper'

class MailNotificationTest < ActiveSupport::TestCase
  test 'can initialize with no arguments' do
    assert MailNotification.new
  end

  test 'can initialize with a hash argument' do
    assert MailNotification.new :name => 'test'
  end

  test "can find notification as hash key" do
    mailer = FactoryBot.create(:mail_notification)
    assert_equal MailNotification[mailer.name], mailer
  end

  test "user with mail disabled doesn't get mail" do
    user = FactoryBot.create(:user, :with_mail, :mail_enabled => false)
    user.mail_notifications << MailNotification[:config_summary]
    notification = user.user_mail_notifications.find_by_mail_notification_id(MailNotification[:config_summary])

    assert_no_difference "ActionMailer::Base.deliveries.size" do
      notification.deliver
    end
  end

  test "#deliver generates mails for each user in :users option" do
    users = FactoryBot.create_pair(:user, :with_mail)
    mailer = FactoryBot.create(:mail_notification)
    mail = mock('mail')
    mail.expects(:deliver_now).twice
    HostMailer.expects(:test_mail).with(:foo, :user => users[0]).returns(mail)
    HostMailer.expects(:test_mail).with(:foo, :user => users[1]).returns(mail)
    mailer.deliver(:foo, :users => users)
  end

  test "'config_error_state' type is ConfigManagementError" do
    mailer = MailNotification.new(:name => 'config_error_state')
    assert_equal 'ConfigManagementError', mailer.type
  end
end
