class Setting::Notification < Setting
  def self.default_settings
    [
      self.set('rss_enable', N_('Whether to pull RSS notifications or not'), true, N_('RSS enable')),
      self.set('rss_url', N_('URL to fetch RSS notifications from'), 'https://theforeman.org/feed.xml', N_('RSS URL'))
    ]
  end

  def self.load_defaults
    # Check the table exists
    return unless super

    self.transaction do
      default_settings.each { |s| self.create! s.update(:category => "Setting::Notification")}
    end

    true
  end

  def self.humanized_category
    N_('Notifications')
  end
end
