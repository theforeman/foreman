namespace :rss do
  desc <<~END_DESC
    Create notifications from an RSS feed.

    By default, the last 3 posts from the feed are sent to a global audience,
    and expire in one week since the announcement. Previous posts in the feed will not
    create a new notification unless "FOREMAN_RSS_FORCE_REPOST" is set to true.

    This will trigger a job that will check for notifications every 12 hours.

    It accepts the following environment variables:
     - FOREMAN_RSS_URL
       + An RSS URL and finds the latest posts, by default 'https://theforeman.org/feed.xml'
     - FOREMAN_RSS_LATEST_POSTS
       + The number of latest posts to retrieve, by default '3'
     - FOREMAN_RSS_FORCE_REPOST
       + If 'true', the task will send notifications again for posts in the RSS feed that already created
         notifications.
       + For example, on the first run of this task, it creates notifications for the latest 3 posts,
         "Newsletter December", "Newsletter November", "Newsletter October". If you run it again without
         FOREMAN_RSS_FORCE_REPOST, no new notifications will be created for these three posts. If you do,
         the task will create notifications once again for "Newsletter December", November and October.
     - FOREMAN_RSS_AUDIENCE
       + The audience that will recieve the notification. By default, 'global'
       + Possible values:
         - 'global' - All users will receive the notification
         - 'admin' - Only administrator users will receive the notification

    Examples:
      # foreman-rake rss:create_notifications FOREMAN_RSS_AUDIENCE='admin'
  END_DESC

  task :create_notifications => :environment do
    posts = ENV.key?('FOREMAN_RSS_LATEST_POSTS') ? ENV['FOREMAN_RSS_LATEST_POSTS'].to_i : 3

    rss_checker = UINotifications::RssNotificationsChecker.new(
      :url => ENV['FOREMAN_RSS_URL'],
      :latest_posts => posts,
      :audience => ENV['FOREMAN_RSS_AUDIENCE'],
      :force_repost => ENV['FOREMAN_RSS_FORCE_REPOST'] == 'true'
    )
    rss_checker.deliver!
  end
end
