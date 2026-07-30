require 'test_helper'
require Rails.root.join('db/migrate/20260811093000_add_skippable_to_mail_notifications.rb')

class AddSkippableToMailNotificationsTest < ActiveSupport::TestCase
  let(:migration) { AddSkippableToMailNotifications.new.tap { |m| m.verbose = false } }

  teardown do
    unless MailNotification.column_names.include?('skippable')
      migration.migrate(:up)
      MailNotification.reset_column_information
    end
  end

  # Skipping only works for mailers that call #skip_empty?, so notifications
  # have to opt in through the seeds rather than be skippable by default. That
  # includes the ones plugins have already created.
  test 'leaves existing notifications not skippable' do
    notification = FactoryBot.create(:mail_notification)

    remigrate

    assert_equal false, notification.reload.skippable
    refute notification.skippable?
  end

  test 'adds a boolean column that defaults to not skippable' do
    remigrate

    column = MailNotification.columns_hash['skippable']
    assert_equal :boolean, column.type
    assert_equal false, MailNotification.column_defaults['skippable']
  end

  test 'is reversible' do
    migration.migrate(:down)
    MailNotification.reset_column_information

    refute_includes MailNotification.column_names, 'skippable'

    migration.migrate(:up)
    MailNotification.reset_column_information

    assert_includes MailNotification.column_names, 'skippable'
  end

  private

  def remigrate
    migration.migrate(:down)
    MailNotification.reset_column_information
    migration.migrate(:up)
    MailNotification.reset_column_information
  end
end
