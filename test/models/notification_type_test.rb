require 'test_helper'

class NotificationTypeTest < ActiveSupport::TestCase
  should validate_presence_of(:message)
  should validate_presence_of(:level)
  should validate_presence_of(:audience)

  test 'user notifications should subscribe only to itself' do
    initiator = user = users(:admin)
    type = FactoryGirl.build(:notification_type, :audience => NotificationType::AUDIENCE_USER)
    assert_equal [user.id], type.subscriber_ids(initiator, user)
  end

  test 'usergroup notifications should subscribe to all of its members' do
    initiator = users(:admin)
    group = FactoryGirl.create(:usergroup)
    group.users = FactoryGirl.create_list(:user,25)
    type = FactoryGirl.build(:notification_type, :audience => NotificationType::AUDIENCE_GROUP)
    assert group.all_users.any?
    assert_equal group.all_users.map(&:id), type.subscriber_ids(initiator, group)
  end

  test 'Organization notifications should subscribe to all of its members' do
    initiator = users(:admin)
    org = FactoryGirl.create(:organization)
    org.users = FactoryGirl.create_list(:user,25)
    type = FactoryGirl.build(:notification_type, :audience => NotificationType::AUDIENCE_TAXONOMY)
    assert org.user_ids.any?
    assert_equal org.user_ids, type.subscriber_ids(initiator, org)
  end

  test 'Location notifications should subscribe to all of its members' do
    initiator = users(:admin)
    loc = FactoryGirl.create(:location)
    loc.users = FactoryGirl.create_list(:user,25)
    type = FactoryGirl.build(:notification_type, :audience => NotificationType::AUDIENCE_TAXONOMY)
    assert loc.user_ids.any?
    assert_equal loc.user_ids, type.subscriber_ids(initiator, loc)
  end

  test 'Global notifications should subscribe to all users' do
    initiator = users(:admin)
    type = FactoryGirl.build(:notification_type, :audience => NotificationType::AUDIENCE_GLOBAL)
    assert User.count > 0
    assert_equal User.reorder('').pluck(:id), type.subscriber_ids(initiator)
  end

  test 'Admin notifications should subscribe to all admin users' do
    initiator = users(:admin)
    type = FactoryGirl.build(:notification_type, :audience => NotificationType::AUDIENCE_ADMIN)
    assert User.only_admin.count > 0
    assert_equal User.only_admin.reorder('').pluck(:id), type.subscriber_ids(initiator)
  end
end
