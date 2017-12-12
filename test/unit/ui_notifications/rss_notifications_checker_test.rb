require 'test_helper'
require 'ostruct'

module UINotifications
  class RssNotificationsCheckerTest < ActiveSupport::TestCase
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
        feed = OpenStruct.new(:items => [rss_item_1, rss_item_2])
        RSS::Parser.expects(:parse).returns(feed)
        Notification.expects(:create).once
        @notifications_service.deliver!
      end

      test 'expect request should include a user agent' do
        assert @notifications_service.send(:rss_user_agent) =~ /Foreman/
      end
    end
  end
end
