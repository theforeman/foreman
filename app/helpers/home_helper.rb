module HomeHelper

  def top_menu_items
    items =  [{:menu_items => hosts_menu_items, :menu_title => _("Hosts")}]
    items += [{:menu_items => provision_menu_items, :menu_title => _("Provision")}] if SETTINGS[:unattended]
    items += [{:menu_items => config_menu_items, :menu_title => _("Configure")},
              {:menu_items => monitor_menu_items, :menu_title => _("Monitor")}]
    items
  end

  def config_menu_items
    [::Menu::Item.new(_('Environments'),           hash_for_environments_path),
     ::Menu::Item.new(_('Global parameters'),      hash_for_common_parameters_path),
     ::Menu::Item.new(_('Host groups'),            hash_for_hostgroups_path),
     ::Menu::Item.new(_('Puppet classes'),         hash_for_puppetclasses_path),
     ::Menu::Item.new(_('Smart variables'),        hash_for_lookup_keys_path),
     ::Menu::Item.new(_('Smart proxies'),          hash_for_smart_proxies_path)]
  end

  def monitor_menu_items
    [::Menu::Item.new(_('Dashboard'),              hash_for_dashboard_path),
     ::Menu::Item.new(_('Reports'),                hash_for_reports_path.merge(:search => 'eventful = true')),
     ::Menu::Item.new(_('Statistics'),             hash_for_statistics_path),
     ::Menu::Item.new(_('Trends'),                 hash_for_trends_path),
     ::Menu::Item.new(_('Audits'),                 hash_for_audits_path)]
  end

  def provision_menu_items
    [::Menu::Item.new(_('Architectures'),          hash_for_architectures_path),
     ::Menu::Item.new(_('Compute resources'),      hash_for_compute_resources_path),
     ::Menu::Item.new(_('Domains'),                hash_for_domains_path),
     ::Menu::Item.new(_('Hardware models'),        hash_for_models_path),
     ::Menu::Item.new(_('Installation media'),     hash_for_media_path),
     ::Menu::Item.new(_('Operating systems'),      hash_for_operatingsystems_path),
     ::Menu::Item.new(_('Partition tables'),       hash_for_ptables_path),
     ::Menu::Item.new(_('Provisioning templates'), hash_for_config_templates_path),
     ::Menu::Item.new(_('Subnets'),                hash_for_subnets_path)]
  end

  def users_menu_items
    menu_items = [
      ::Menu::Item.new(_('LDAP authentication'),   hash_for_auth_source_ldaps_path),
      ::Menu::Item.new(_('Users'),                 hash_for_users_path),
      ::Menu::Item.new(_('User groups'),           hash_for_usergroups_path)
    ]
    menu_items += [::Menu::Item.new(_('Roles'),    hash_for_roles_path)] if User.current && User.current.admin?
    menu_items
  end

  def hosts_menu_items
    [::Menu::Item.new(_('All hosts'),              hash_for_hosts_path),
     ::Menu::Item.new(_('Facts'),                  hash_for_fact_values_path )]
  end

  def admin_menu_items
    menu_items = []
    menu_items += [::Menu::Item.new(_('Locations'),     hash_for_locations_path)]     if SETTINGS[:locations_enabled]
    menu_items += [::Menu::Item.new(_('Organizations'), hash_for_organizations_path)] if SETTINGS[:organizations_enabled]
    menu_items += [::Menu::Divider.new] + users_menu_items if SETTINGS[:login]
    menu_items += [
      ::Menu::Divider.new,
      ::Menu::Item.new(_('Bookmarks'),             hash_for_bookmarks_path),
      ::Menu::Item.new(_('Settings'),              hash_for_settings_path),
      ::Menu::Item.new(_('About'),                 hash_for_about_index_path)
    ]
    menu_items
  end

  def authorized_menu_actions(choices)
    last_item = ::Menu::Divider.new
    choices = choices.map do |item|
      case item
        when ::Menu::Divider
          last_item = item unless last_item.is_a?(::Menu::Divider) #prevent adjacent dividers
        when ::Menu::Item
          last_item = item if item.authorized?
        when ::Menu::Submenu
          last_item = item if item.sub_items.size > 0
      end
    end.compact
    choices.pop if (choices.last.is_a?(::Menu::Divider))
    choices
  end

  def menu_item_tag item
    content_tag(:li, link_to(item.display, item.url_hash), :class => "menu_tab_#{item.url_hash[:controller]} ")
  end

  def org_switcher_title
    title = if Organization.current && Location.current
      Organization.current.to_label + "@" + Location.current.to_label
    elsif Organization.current
      Organization.current.to_label
    elsif Location.current
      Location.current.to_label
    else
      _("Any Context")
    end
    title
  end

  def user_header
    summary = gravatar_image_tag(User.current.mail, :class=>'gravatar small', :alt=>_('Change your avatar at gravatar.com')) +
              "#{User.current.to_label} " + content_tag(:span, "", :class=>'caret')
    link_to(summary.html_safe, "#", :class => "dropdown-toggle", :'data-toggle'=>"dropdown")
  end

end
