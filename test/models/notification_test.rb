require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  should validate_presence_of(:initiator)
  should validate_presence_of(:notification_blueprint)
  should validate_presence_of(:audience)

  test 'should be able to create notification' do
    blueprint = FactoryGirl.create(
      :notification_blueprint,
      :message => 'this test just executed successfully',
      :subject => nil
    )
    notice = FactoryGirl.create(:notification,
                                :audience => 'global',
                                :notification_blueprint => blueprint)
    assert notice.valid?
    assert_equal blueprint.message, notice.notification_blueprint.message
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
    notification = FactoryGirl.build(:notification,
                                     :audience => Notification::AUDIENCE_USER)
    assert_equal [notification.initiator.id], notification.subscriber_ids
  end

  test 'usergroup notifications should subscribe to all of its members' do
    group = FactoryGirl.create(:usergroup)
    group.users = FactoryGirl.create_list(:user,25)
    notification = FactoryGirl.build(:notification,
                                     :audience => Notification::AUDIENCE_GROUP)
    notification.notification_blueprint.subject = group
    assert group.all_users.any?
    assert_equal group.all_users.map(&:id),
      notification.subscriber_ids
  end

  test 'Organization notifications should subscribe to all of its members' do
    org = FactoryGirl.create(:organization)
    org.users = FactoryGirl.create_list(:user,25)
    notification = FactoryGirl.build(:notification,
                                     :audience => Notification::AUDIENCE_TAXONOMY)
    notification.notification_blueprint.subject = org
    assert org.user_ids.any?
    assert_equal org.user_ids, notification.subscriber_ids
  end

  test 'Location notifications should subscribe to all of its members' do
    loc = FactoryGirl.create(:location)
    loc.users = FactoryGirl.create_list(:user,25)
    notification = FactoryGirl.build(:notification,
                                     :audience => Notification::AUDIENCE_TAXONOMY)
    notification.notification_blueprint.subject = loc
    assert loc.user_ids.any?
    assert_equal loc.user_ids, notification.subscriber_ids
  end

  test 'Global notifications should subscribe to all users' do
    notification = FactoryGirl.build(:notification,
                                     :audience => Notification::AUDIENCE_GLOBAL)
    assert User.count > 0
    assert_equal User.reorder('').pluck(:id),
      notification.subscriber_ids
  end

  test 'Admin notifications should subscribe to all admin users' do
    notification = FactoryGirl.build(:notification,
                                     :audience => Notification::AUDIENCE_ADMIN)
    assert User.only_admin.count > 0
    assert_equal User.only_admin.reorder('').pluck(:id).sort,
      notification.subscriber_ids.sort
  end
end
