class Setting::Notification < Setting
  def self.default_settings
    [
      self.set('rss_enable', N_('Whether to pull RSS notifications or not'), true, N_('RSS enable')),
      self.set('rss_url', N_('URL to fetch RSS notifications from'), 'https://theforeman.org/feed.xml', N_('RSS URL')),
      self.set('releases_tracking_enable', N_('Whether to pull release notifications or not'), true, N_('Releases tracking enable')),
      self.set('releases_track_rc_enable', N_('Whether to include release candidates in the notifications'), false, N_('RC Release tracking enable')),
      self.set('releases_tracking_url', N_('URL to fetch release notifications from'), 'https://github.com/theforeman/foreman/releases.atom', N_('Releases URL')),
    ]
  end

  def self.humanized_category
    N_('Notifications')
  end
end
