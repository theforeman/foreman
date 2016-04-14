require 'test_helper'

class LatestNewsTest < ActiveSupport::TestCase
  setup do
    Setting[:latest_news_rss_feed] = File.expand_path(File.dirname(__FILE__) + '/rss_feed.xml')
  end

  test "#items returns 8 items" do
    assert_equal 8, LatestNews.items.size
  end

  test "#last_updated does not update before the configured interval" do
    LatestNews.items
    LatestNews.class_eval { @last_updated = 25.minutes.ago }
    old_last_updated = LatestNews.last_updated
    LatestNews.items

    assert_equal old_last_updated, LatestNews.last_updated
  end

  test "#last_updated updates after the configured interval" do
    LatestNews.items
    LatestNews.class_eval { @last_updated = 35.minutes.ago }
    old_last_updated = LatestNews.last_updated
    LatestNews.items

    assert old_last_updated < LatestNews.last_updated
  end

  test "#items does not raise when there's a problem retrieving the feed" do
    assert_nothing_raised do
      Setting[:latest_news_rss_feed] = '/non/existant/path/should/not/raise'
      LatestNews.class_eval { @last_updated = 60.minutes.ago }
    end

    assert_empty LatestNews.items
  end
end
