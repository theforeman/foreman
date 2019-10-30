require 'rss'
require 'date'
require "net/http"
require "uri"

module UINotifications
  class ReleaseNotificationsChecker
    class Item
      def initialize(feed_item)
        @item = feed_item
      end

      def link
        @link ||= @item.link.respond_to?(:href) ? @item.link.href : @item.link
      end

      def title
        @title ||= @item.title.respond_to?(:content) ? @item.title.content : @item.title
      end
    end

    def initialize(options = {})
      @url = options[:url] || Setting[:releases_tracking_url]
      @audience = options[:audience] || Notification::AUDIENCE_ADMIN
    end

    def deliver!
      return true unless Setting[:releases_tracking_enable]
      
      current_version = SETTINGS[:version]
      all_releases = Array.new

      while !all_releases.select { |release| release.title == current_version }.any?
        releases_feed = load_releases_feed( all_releases.last.nil? ? nil : all_releases.last.title )
        all_releases.concat(RSS::Parser.parse(releases_feed, false).items.map { |release| Item.new(release) })
      end

      all_releases = all_releases.sort_by { |feed_item| Gem::Version.new(feed_item.title) }

      all_rcs = all_releases.select { |release| Gem::Version.new(release.title).prerelease? }
      all_releases = all_releases.select { |release| !Gem::Version.new(release.title).prerelease? }
      
      minor_version = current_version.split('.')[0, 2].join('.')
      last_patch_version = all_releases.select { |item| item.title.starts_with?(minor_version) }.last
      last_upgrade = all_releases.last
      last_rc_version = all_rcs.select { |item| item.title.starts_with?(minor_version) }.last

      if (!last_patch_version.nil? && Gem::Version.new(last_patch_version.title) != Gem::Version.new(current_version))
        notify_release('update', last_patch_version.title, last_patch_version.link)
      end

      if Gem::Version.new(last_upgrade.title) > Gem::Version.new(current_version)
        notify_release('upgrade', last_upgrade.title, last_upgrade.link);
      end

      if (!last_rc_version.nil? && Gem::Version.new(last_rc_version.title) != Gem::Version.new(current_version) && Setting[:releases_track_rc_enable])
        notify_release('release candidate', last_rc_version.title, last_rc_version.link)        
      end
    end

    private

    def release_notification_blueprint
      NotificationBlueprint.unscoped.find_by_name('releases')
    end

    def notification_already_exists?(title)
      !!Notification.unscoped.find_by_message(title)
    end

    def notify_release(type, version, link) 
      blueprint = release_notification_blueprint
      return false unless blueprint

      message = UINotifications::StringParser.new(blueprint.message, {version: version, release_type: type}).to_s
      return true if notification_already_exists?(message)

      Notification.create(
        :initiator => User.anonymous_admin,
        :audience => @audience,
        :message => message,
        :notification_blueprint => blueprint,
        :actions => {
          :links => [
            {
              :href => link,
              :title => _('Open'),
              :external => true,
            },
          ],
        }
      )
    end

    def load_releases_feed(after = nil)
      uri = URI.parse(@url)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri.request_uri.concat("?after=#{after}"))
        request.initialize_http_header({"User-Agent" => rss_user_agent})
        result = http.request(request)
        if result.code.start_with?('2')
          result.body
        else
          Foreman::Logging.logger('notifications').warn "Fetching releases failed with code #{result.code}"
          nil
        end
      end
    rescue => e
      Foreman::Logging.exception "Fetching releases failed", e, :logger => 'notifications'
      nil
    end

    def rss_user_agent
      "Foreman/#{SETTINGS[:version]} (Releases notifications)"
    end
  end
end
