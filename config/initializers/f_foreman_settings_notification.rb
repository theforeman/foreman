Foreman::SettingManager.define(:foreman) do
  category(:notification, N_('Notifications')) do
    setting('rss_enable',
      type: :boolean,
      description: N_('Whether to pull RSS notifications or not'),
      default: true,
      full_name: N_('RSS enable'))
    setting('rss_url',
      type: :string,
      description: N_('URL to fetch RSS notifications from'),
      default: 'https://theforeman.org/feed.xml',
      full_name: N_('RSS URL'))
  end
end
