require 'simple-rss'

class LatestNews
  attr_reader :title, :url, :date

  def initialize(title, url, date)
    @title = title
    @url = url
    @date = date
  end

  class << self
    attr_reader :last_updated

    def items
      if @last_updated && (Time.now.utc < (@last_updated + 30.minutes))
        return @items
      else
        return fetch_new_items
      end
    end

    private

    def fetch_new_items
      return {} unless Setting[:latest_news_rss_feed].present?

      @items = []
      feed = SimpleRSS.parse(open(Setting[:latest_news_rss_feed]))

      feed.items[0,8].each do |item|
        @items << self.new(item.title, item.link, item.updated)
      end

      @last_updated = Time.now.utc
      @items
    rescue => e
      Rails.logger.error("There was a problem loading the latest news RSS feed: #{e}")
      @items = []
    end
  end
end
