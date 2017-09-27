require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  should validate_presence_of(:initiator)
  should validate_presence_of(:notification_blueprint)
  should validate_presence_of(:audience)

  should have_many(:notification_recipients).dependent(:destroy)

  test 'should be able to create notification' do
    blueprint = FactoryGirl.create(
      :notification_blueprint,
      :message => 'this test just executed successfully'
    )
    notice = FactoryGirl.create(:notification,
                                :audience => 'global',
                                :notification_blueprint => blueprint)
    assert notice.valid?
    assert_equal blueprint.message, notice.message
    assert_equal User.all, notice.recipients
  end

  test 'should return active notifications' do
    blueprint = FactoryGirl.create(
      :notification_blueprint,
      :expires_in => 5.minutes
    )
    notice = FactoryGirl.create(:notification,
                                :audience => Notification::AUDIENCE_ADMIN,
                                :notification_blueprint => blueprint)
    assert_includes Notification.active, notice
  end

  test 'user notifications should subscribe only to itself' do
    notification = FactoryGirl.create(:notification,
                                      :subject => User.current,
                                      :audience => Notification::AUDIENCE_USER)
    assert_equal [User.current.id], notification.subscriber_ids
  end

  test 'usergroup notifications should subscribe to all of its members' do
    group = FactoryGirl.create(:usergroup)
    group.users = FactoryGirl.create_list(:user,25)
    notification = FactoryGirl.build(:notification,
                                     :audience => Notification::AUDIENCE_USERGROUP)
    notification.subject = group
    assert group.all_users.any?
    assert_equal group.all_users.map(&:id).sort,
      notification.subscriber_ids.sort
  end

  test 'Organization notifications should subscribe to all of its members' do
    org = FactoryGirl.create(:organization)
    org.users = FactoryGirl.create_list(:user,25)
    notification = FactoryGirl.build(:notification,
                                     :audience => Notification::AUDIENCE_SUBJECT)
    notification.subject = org
    assert org.user_ids.any?
    assert_equal org.user_ids.sort, notification.subscriber_ids.sort
  end

  test 'Location notifications should subscribe to all of its members' do
    loc = FactoryGirl.create(:location)
    loc.users = FactoryGirl.create_list(:user,25)
    notification = FactoryGirl.build(:notification,
                                     :audience => Notification::AUDIENCE_SUBJECT)
    notification.subject = loc
    assert loc.user_ids.any?
    assert_equal loc.user_ids.sort, notification.subscriber_ids.sort
  end

  test 'Global notifications should subscribe to all users' do
    notification = FactoryGirl.build(:notification,
                                     :audience => Notification::AUDIENCE_GLOBAL)
    assert User.count > 0
    assert_equal User.reorder('').pluck(:id).sort,
      notification.subscriber_ids.sort
  end

  test 'Admin notifications should subscribe to all admin users except hidden' do
    notification = FactoryGirl.build(:notification,
                                     :audience => Notification::AUDIENCE_ADMIN)
    admin = FactoryGirl.create(:user, :admin)

    subscriber_ids = notification.subscriber_ids
    assert_includes subscriber_ids, admin.id
    refute_includes subscriber_ids, User.anonymous_admin.id
    refute_includes subscriber_ids, User.anonymous_api_admin.id
  end

  test 'notification message should be stored' do
    host = FactoryGirl.create(:host)
    blueprint = FactoryGirl.create(
      :notification_blueprint,
      :message => "%{subject} has been lost",
      :level => 'error'
    )
    notice = FactoryGirl.create(:notification,
      :audience => 'global',
      :subject => host,
      :notification_blueprint => blueprint)
    assert_equal "#{host} has been lost", notice.message
  end
end
