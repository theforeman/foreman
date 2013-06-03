module HomeHelper

  def class_for_setting_page
    setting_options.flatten.include?(controller_name.to_sym) ? "active" : ""
  end

  def setting_options
    configuration_group =
        [[_('Environments'),          :environments],
        [_('Global Parameters'),      :common_parameters],
        [_('Host Groups'),            :hostgroups],
        [_('Puppet Classes'),         :puppetclasses],
        [_('Smart Variables'),        :lookup_keys],
        [_('Smart Proxies'),          :smart_proxies]]
    choices = [ [:group, _("Configuration"), configuration_group]]

    if SETTINGS[:unattended]
      provisioning_group =
          [[_('Architectures'),          :architectures],
          [_('Compute Resources'),      :compute_resources],
          [_('Domains'),                :domains],
          [_('Hardware Models'),        :models],
          [_('Installation Media'),     :media],
          [_('Operating Systems'),      :operatingsystems],
          [_('Partition Tables'),       :ptables],
          [_('Provisioning Templates'), :config_templates],
          [_('Subnets'),                :subnets]]
      choices += [[:divider], [:group, _("Provisioning"), provisioning_group]]
    end

    if (SETTINGS[:organizations_enabled] or SETTINGS[:locations_enabled])
      choices += [[:divider]]
      choices += [ [_('Locations'), :locations] ]         if SETTINGS[:locations_enabled]
      choices += [ [_('Organizations'), :organizations] ] if SETTINGS[:organizations_enabled]
    end

    users_group =
      [[_('LDAP Authentication'),    :auth_source_ldaps],
      [_('Users'),                  :users],
      [_('User Groups'),            :usergroups]]
    users_group += [[_('Roles'),     :roles]] if User.current && User.current.admin?

    choices += [[:divider], [:group, _("Users"), users_group] ] if SETTINGS[:login]

    choices += [
      [:divider],
      [_('Bookmarks'),              :bookmarks],
      [_('Settings'),               :settings]
    ]

    authorized_menu_actions(choices)+[[_('About'), :about]]
  end

  def authorized_menu_actions(choices)
    last_item = nil
    choices = choices.map do |item|
      #prevent adjacent dividers
      if item == [:divider]
        if last_item
          last_item = nil
          item
        end
      elsif item.size == 2 && authorized_for(item[1], :index)
        last_item = item
        item
      elsif item.size == 3
        item[2] = item[2].map do |sub_item|
          sub_item if authorized_for(sub_item[1], :index)
        end.compact
        if item[2].size > 0
          last_item = item
          item
        end
      end
    end.compact
    choices.pop if (choices.last == [:divider])
    choices
  end

  def menu(tab, label, path = nil)
    path ||= send("hash_for_#{tab}_path")
    return '' unless authorized_for(path[:controller], path[:action] )
    content_tag(:li, :class => "menu_tab_#{tab} ") do
      link_to_if_authorized(label, path)
    end
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

  # filters out any non allowed actions from the setting menu.
  def allowed_choices choices, action = "index"
    choices.map do |opt|
      name, kontroller = opt
      url = send("#{kontroller}_url")
      authorized_for(kontroller, action) ? [name, url] : nil
    end.compact.sort
  end

  def user_header
    summary = gravatar_image_tag(User.current.mail, :class=>'gravatar small', :alt=>_('Change your avatar at gravatar.com')) +
              "#{User.current.to_label} " + content_tag(:span, "", :class=>'caret')
    link_to(summary.html_safe, "#", :class => "dropdown-toggle", :'data-toggle'=>"dropdown")
  end

end
