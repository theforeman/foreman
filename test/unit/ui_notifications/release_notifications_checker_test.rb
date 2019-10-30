require 'test_helper'
require 'ostruct'

module UINotifications
  class ReleaseNotificationsCheckerTest < ActiveSupport::TestCase
    context 'when checking for new releases' do
      setup do
        @notifications_service = ReleaseNotificationsChecker.new()
      end

      test 'Show updates & upgrades but skip release candidates' do
        notification = Notification.new

        unscoped_mock = mock()
        unscoped_mock.expects(:find_by_message).with('New update (v1.21.1) available!').returns(nil)
        unscoped_mock.expects(:find_by_message).with('New upgrade (v1.25.0) available!').returns(nil)
        Notification.stubs(:unscoped).returns(unscoped_mock)
 
        Setting[:releases_track_rc_enable] = false
        SETTINGS[:version] = "1.21.0"

        rss_item_1 = mock()
        rss_item_1.stubs(:title).returns('1.25.0')
        rss_item_1.stubs(:link).returns('https://fakehub.com/1.25.0/')

        rss_item_2 = mock()
        rss_item_2.stubs(:title).returns('1.24.0')
        rss_item_2.stubs(:link).returns('https://fakehub.com/1.24.0/')

        rss_item_3 = mock()
        rss_item_3.stubs(:title).returns('1.22.1')
        rss_item_3.stubs(:link).returns('https://fakehub.com/1.22.1/')

        rss_item_4 = mock()
        rss_item_4.stubs(:title).returns('1.21.0')
        rss_item_4.stubs(:link).returns('https://fakehub.com/1.21.0/')

        rss_item_5 = mock()
        rss_item_5.stubs(:title).returns('1.21.1')
        rss_item_5.stubs(:link).returns('https://fakehub.com/1.21.1/')

        rss_item_6 = mock()
        rss_item_6.stubs(:title).returns('1.21.2-RC1')
        rss_item_6.stubs(:link).returns('https://fakehub.com/1.21.2-RC1/')

        @notifications_service.stubs(:load_releases_feed).returns('something')
        feed_1 = OpenStruct.new(:items => [rss_item_1,rss_item_2,rss_item_3])
        feed_2 = OpenStruct.new(:items => [rss_item_4,rss_item_5,rss_item_6])
        RSS::Parser.expects(:parse).twice.returns(feed_1, feed_2)
        Notification.expects(:create).twice        

        @notifications_service.deliver!
      end

      test 'Show updates, upgrades & release candidates' do
        notification = Notification.new

        unscoped_mock = mock()
        unscoped_mock.expects(:find_by_message).with('New update (v1.21.1) available!').returns(nil)
        unscoped_mock.expects(:find_by_message).with('New upgrade (v1.25.0) available!').returns(nil)
        unscoped_mock.expects(:find_by_message).with('New release candidate (v1.21.2-RC1) available!').returns(nil)
        Notification.stubs(:unscoped).returns(unscoped_mock)

        Setting[:releases_track_rc_enable] = true
        SETTINGS[:version] = "1.21.0"

        rss_item_1 = mock()
        rss_item_1.stubs(:title).returns('1.25.0')
        rss_item_1.stubs(:link).returns('https://fakehub.com/1.25.0/')

        rss_item_2 = mock()
        rss_item_2.stubs(:title).returns('1.24.0')
        rss_item_2.stubs(:link).returns('https://fakehub.com/1.24.0/')

        rss_item_3 = mock()
        rss_item_3.stubs(:title).returns('1.22.1')
        rss_item_3.stubs(:link).returns('https://fakehub.com/1.22.1/')

        rss_item_4 = mock()
        rss_item_4.stubs(:title).returns('1.21.0')
        rss_item_4.stubs(:link).returns('https://fakehub.com/1.21.0/')

        rss_item_5 = mock()
        rss_item_5.stubs(:title).returns('1.21.1')
        rss_item_5.stubs(:link).returns('https://fakehub.com/1.21.1/')

        rss_item_6 = mock()
        rss_item_6.stubs(:title).returns('1.21.2-RC1')
        rss_item_6.stubs(:link).returns('https://fakehub.com/1.21.2-RC1/')

        @notifications_service.stubs(:load_releases_feed).returns('something')
        feed_1 = OpenStruct.new(:items => [rss_item_1,rss_item_2,rss_item_3])
        feed_2 = OpenStruct.new(:items => [rss_item_4,rss_item_5,rss_item_6])
        RSS::Parser.expects(:parse).twice.returns(feed_1, feed_2)
        Notification.expects(:create).times(3)        

        @notifications_service.deliver!
      end
    end
  end
end
