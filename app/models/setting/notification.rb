class Setting::Notification < Setting
  def self.default_settings
    [
      set('rss_enable', N_('Whether to pull RSS notifications or not'), true, N_('RSS enable')),
      set('rss_url', N_('URL to fetch RSS notifications from'), 'https://theforeman.org/feed.xml', N_('RSS URL')),
    ]
  end

  def self.humanized_category
    N_('Notifications')
  end
end
