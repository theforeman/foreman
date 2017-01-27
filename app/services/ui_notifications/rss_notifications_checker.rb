require 'rss'
require 'date'

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

    def initialize(options = [])
      @url = options[:url] || Setting[:rss_url]
      @latest_posts = options[:latest_posts] || 3
      @force_repost = options[:force_repost] || false
      @audience = options[:audience] || Notification::AUDIENCE_GLOBAL
    end

    def deliver!
      # This is a noop every time rss_enable=false, the moment it
      # gets enabled, notifications for RSS feeds are created again
      return true unless Setting[:rss_enable]
      feed = RSS::Parser.parse(@url, false)
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
                :external => true
              }
            ]
          }
        )
      end
    end

    private

    def rss_notification_blueprint
      NotificationBlueprint.unscoped.find_by_name('rss_post')
    end

    def notification_already_exists?(item)
      !!Notification.unscoped.find_by_message(item.summary)
    end
  end
end
