require 'test_helper'
require 'ostruct'
require 'notifications_test_helper'

module UINotifications
  class RssNotificationsCheckerTest < ActiveSupport::TestCase
    include NotificationBlueprintSeeds

    context 'when force_repost is disabled' do
      setup do
        @notifications_service = RssNotificationsChecker.new(:force_repost => false)
      end

      test 'already existing notifications are not created' do
        notification = Notification.new
        unscoped_mock = mock()
        unscoped_mock.expects(:find_by_message).with('hello').returns(notification)
        Notification.stubs(:unscoped).returns(unscoped_mock)

        rss_item_1 = mock()
        rss_item_1.stubs(:title).returns('hello')

        @notifications_service.stubs(:load_rss_feed).returns('something')
        feed = OpenStruct.new(:items => [rss_item_1])
        RSS::Parser.expects(:parse).returns(feed)
        Notification.expects(:create).never
        @notifications_service.deliver!
      end

      test 'mix of notifications' do
        notification = Notification.new
        unscoped_mock = mock()
        unscoped_mock.expects(:find_by_message).with('hello').returns(notification)
        unscoped_mock.expects(:find_by_message).with('world').returns(nil)
        Notification.stubs(:unscoped).returns(unscoped_mock)

        rss_item_1 = mock()
        rss_item_1.stubs(:title).returns('hello')
        rss_item_2 = mock()
        rss_item_2.stubs(:title).returns('world')
        rss_item_2.stubs(:link).returns('http://world.com')
        @notifications_service.stubs(:load_rss_feed).returns('something')
        @notifications_service.stubs(:notification_exists_for_link?).returns(false)
        feed = OpenStruct.new(:items => [rss_item_1, rss_item_2])
        RSS::Parser.expects(:parse).returns(feed)
        Notification.expects(:create).once
        @notifications_service.deliver!
      end

      test 'does not create notification when link already exists' do
        unscoped_mock = mock()
        unscoped_mock.expects(:find_by_message).with('world').returns(nil)
        Notification.stubs(:unscoped).returns(unscoped_mock)

        rss_item = mock()
        rss_item.stubs(:title).returns('world')
        rss_item.stubs(:link).returns('http://world.com')
        @notifications_service.stubs(:load_rss_feed).returns('something')
        @notifications_service.stubs(:notification_exists_for_link?).with('http://world.com').returns(true)
        feed = OpenStruct.new(:items => [rss_item])
        RSS::Parser.expects(:parse).returns(feed)
        Notification.expects(:create).never
        @notifications_service.deliver!
      end

      test 'strips trailing whitespace from feed titles before create and lookup' do
        notification = Notification.new
        unscoped_mock = mock()
        unscoped_mock.expects(:find_by_message).with('hello').returns(notification)
        Notification.stubs(:unscoped).returns(unscoped_mock)

        rss_item = mock()
        rss_item.stubs(:title).returns('hello ')
        @notifications_service.stubs(:load_rss_feed).returns('something')
        feed = OpenStruct.new(:items => [rss_item])
        RSS::Parser.expects(:parse).returns(feed)
        Notification.expects(:create).never
        @notifications_service.deliver!
      end

      test 'expect request should include a user agent' do
        assert @notifications_service.send(:rss_user_agent) =~ /Foreman/
      end

      test 'notification_exists_for_link? matches persisted actions href' do
        blueprint = NotificationBlueprint.find_by_name('rss_post')
        link = 'https://example.com/satellite-6-18'
        Notification.create!(
          :initiator => User.anonymous_admin,
          :audience => Notification::AUDIENCE_GLOBAL,
          :message => 'Introducing Satellite 6.18',
          :notification_blueprint => blueprint,
          :actions => {
            :links => [
              {
                :href => link,
                :title => 'Open',
                :external => true,
              },
            ],
          }
        )

        assert @notifications_service.send(:notification_exists_for_link?, link)
        refute @notifications_service.send(:notification_exists_for_link?, 'https://example.com/other')
      end

      test 'notification_exists_for_link? returns false when blueprint is missing' do
        NotificationBlueprint.stubs(:unscoped).returns(NotificationBlueprint)
        NotificationBlueprint.stubs(:find_by_name).with('rss_post').returns(nil)

        refute @notifications_service.send(:notification_exists_for_link?, 'https://example.com/post')
      end
    end

    describe 'RssNotificationsChecker::Item' do
      test 'title strips leading and trailing whitespace' do
        feed_item = mock()
        feed_item.stubs(:title).returns('  Introducing Satellite 6.18 ')
        item = RssNotificationsChecker::Item.new(feed_item)
        assert_equal 'Introducing Satellite 6.18', item.title
      end

      test 'title strips whitespace from atom content titles' do
        title = mock()
        title.stubs(:content).returns("Introducing Satellite 6.18 ")
        feed_item = mock()
        feed_item.stubs(:title).returns(title)
        item = RssNotificationsChecker::Item.new(feed_item)
        assert_equal 'Introducing Satellite 6.18', item.title
      end
    end
  end
end
