require 'rss/parser'
require 'rss/atom'
require 'rss/1.0'
require 'rss/2.0'
require 'date'
require "net/http"
require "uri"

module UINotifications
  class RssNotificationsChecker
    class Item
      def initialize(feed_item)
        @item = feed_item
      end

      def link
        @link ||= @item.link.respond_to?(:href) ? @item.link.href : @item.link
      end

      def summary
        @summary ||= begin
          summary = @item.summary if @item.respond_to?(:summary)
          summary = @item.description if @item.respond_to?(:description)
          summary.respond_to?(:content) ? summary.content : summary
        end
      end

      def title
        @title ||= @item.title.respond_to?(:content) ? @item.title.content : @item.title
      end
    end

    def initialize(options = {})
      @url = options[:url] || Setting[:rss_url]
      @latest_posts = options[:latest_posts] || 3
      @force_repost = options[:force_repost] || false
      @audience = options[:audience] || Notification::AUDIENCE_GLOBAL
    end

    def deliver!
      # This is a noop every time rss_enable=false, the moment it
      # gets enabled, notifications for RSS feeds are created again
      return true unless Setting[:rss_enable]
      rss_feed = load_rss_feed
      return true if rss_feed.nil?
      feed = RSS::Parser.parse(rss_feed, false)
      feed.items[0, @latest_posts].each do |feed_item|
        item = Item.new(feed_item)
        blueprint = rss_notification_blueprint
        if notification_already_exists?(item)
          next unless @force_repost
        end
        Notification.create(
          :initiator => User.anonymous_admin,
          :audience => @audience,
          :message => item.title,
          :notification_blueprint => blueprint,
          :actions => {
            :links => [
              {
                :href => item.link,
                :title => _('Open'),
                :external => true,
              },
            ],
          }
        )
      end
    end

    private

    def rss_notification_blueprint
      NotificationBlueprint.unscoped.find_by_name('rss_post')
    end

    def notification_already_exists?(item)
      !!Notification.unscoped.find_by_message(item.title)
    end

    def load_rss_feed
      uri = URI.parse(@url)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        request.initialize_http_header({"User-Agent" => rss_user_agent})
        result = http.request(request)
        if result.code.start_with?('2')
          result.body
        else
          Foreman::Logging.logger('notifications').warn "Fetching RSS failed with code #{result.code}"
          nil
        end
      end
    rescue => e
      Foreman::Logging.exception "Fetching RSS failed", e, :logger => 'notifications'
      nil
    end

    def rss_user_agent
      "Foreman/#{SETTINGS[:version]} (RSS notifications)"
    end
  end
end
