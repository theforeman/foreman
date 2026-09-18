require 'test_helper'
require Rails.root.join('db/migrate/20260729144349_add_skip_if_empty_to_user_mail_notifications.rb')

class AddSkipIfEmptyToUserMailNotificationsTest < ActiveSupport::TestCase
  let(:migration) { AddSkipIfEmptyToUserMailNotifications.new.tap { |m| m.verbose = false } }

  teardown do
    unless UserMailNotification.column_names.include?('skip_if_empty')
      migration.migrate(:up)
      UserMailNotification.reset_column_information
    end
  end

  # The column lands on a populated table, so subscriptions that were already
  # there have to come out of the migration still receiving their summaries.
  test 'leaves existing subscriptions receiving empty summaries' do
    subscription = FactoryBot.create(:user_mail_notification)

    remigrate

    assert_equal false, subscription.reload.skip_if_empty
  end

  test 'adds a boolean column that defaults to not skipping' do
    remigrate

    column = UserMailNotification.columns_hash['skip_if_empty']
    assert_equal :boolean, column.type
    assert_equal false, UserMailNotification.column_defaults['skip_if_empty']
  end

  test 'is reversible' do
    migration.migrate(:down)
    UserMailNotification.reset_column_information

    refute_includes UserMailNotification.column_names, 'skip_if_empty'

    migration.migrate(:up)
    UserMailNotification.reset_column_information

    assert_includes UserMailNotification.column_names, 'skip_if_empty'
  end

  private

  def remigrate
    migration.migrate(:down)
    UserMailNotification.reset_column_information
    migration.migrate(:up)
    UserMailNotification.reset_column_information
  end
end
