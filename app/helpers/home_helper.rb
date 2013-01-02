module HomeHelper

  def class_for_setting_page
    setting_options.map{|o| o[1]}.include?(controller_name.to_sym) ? "active" : ""
  end

  def setting_options
    configuration_group =
        [['Environments',           :environments],
        ['Global Parameters',      :common_parameters],
        ['Host Groups',            :hostgroups],
        ['Puppet Classes',         :puppetclasses],
        ['Smart Variables',        :lookup_keys],
        ['Smart Proxies',          :smart_proxies]]
    choices = [ [:group, "Configuration", configuration_group]]

    if SETTINGS[:unattended]
      provisioning_group =
          [['Architectures',          :architectures],
          ['Compute Resources',      :compute_resources],
          ['Domains',                :domains],
          ['Hardware Models',        :models],
          ['Installation Media',     :media],
          ['Operating Systems',      :operatingsystems],
          ['Partition Tables',       :ptables],
          ['Provisioning Templates', :config_templates],
          ['Subnets',                :subnets]]
      choices += [[:divider], [:group, "Provisioning", provisioning_group]]
    end

    if (SETTINGS[:organizations_enabled] or SETTINGS[:locations_enabled])
      choices += [[:divider]]
      choices += [ ['Locations', :locations] ]         if SETTINGS[:locations_enabled]
      choices += [ ['Organizations', :organizations] ] if SETTINGS[:organizations_enabled]
    end

    users_group =
      [['LDAP Authentication',    :auth_source_ldaps],
      ['Users',                  :users],
      ['User Groups',            :usergroups]]
    users_group += [['Roles',     :roles]] if User.current && User.current.admin?

    choices += [[:divider], [:group, "Users", users_group] ] if SETTINGS[:login]

    choices += [
      [:divider],
      ['Bookmarks',              :bookmarks],
      ['Settings',               :settings]
    ]

    #prevent adjacent dividers
    last_item = nil
    choices = choices.map do |item|
      if item == [:divider]
        if last_item
          last_item = nil
          item
        end
      elsif authorized_for(item[1], :index)
        last_item = item
        item
      end
    end.compact
    choices.pop if (choices.last == [:divider])
    choices
  end

  def menu(tab, myBookmarks ,path = nil)
    path ||= eval("hash_for_#{tab}_path")
    return '' unless authorized_for(path[:controller], path[:action] )
    b = myBookmarks.map{|b| b if b.controller == path[:controller]}.compact
    out = content_tag :li, :id => "menu_tab_#{tab}" do
      link_to_if_authorized(tab.capitalize, path, :class => b.empty? ? "" : "narrow-right")
    end
    out +=  content_tag :li, :class => "dropdown hidden-tablet hidden-phone "  do
      link_to(content_tag(:span,'', :'data-toggle'=> 'dropdown', :class=>'caret hidden-phone hidden-tablet'), "#", :class => "dropdown-toggle narrow-left hidden-phone hidden-tablet") + menu_dropdown(b)
    end unless b.empty?
    out
  end

  def menu_dropdown bookmark
    return "" if bookmark.empty?
    render("bookmarks/list", :bookmarks => bookmark)
  end

  # filters out any non allowed actions from the setting menu.
  def allowed_choices choices, action = "index"
    choices.map do |opt|
      name, kontroller = opt
      url = eval("#{kontroller}_url")
      authorized_for(kontroller, action) ? [name, url] : nil
    end.compact.sort
  end

  def user_header
    summary = content_tag(:span, "#{User.current.to_label}  ", :class=>'text-label')
    summary += content_tag(:span, Organization.current.to_label, :class=>'boxed-label') if Organization.current
    summary += content_tag(:span, Location.current.to_label, :class=>'boxed-label') if Location.current
    summary += gravatar_image_tag(User.current.mail, :class=>'gravatar', :alt=>'Change your avatar at gravatar.com') + content_tag(:span, "", :class=>'caret')
    link_to(summary.html_safe, "#", :class => "dropdown-toggle", :'data-toggle'=>"dropdown")
  end

  def gravatar_image_tag(email, html_options = {})
    default_image = "/images/user.jpg"
    html_options.merge!(:onerror=>"this.src='#{default_image}'")
    image_tag(gravatar_url(email, default_image), html_options)
  end

  def gravatar_url(email, default_image)
    return default_image if email.blank?
    "#{request.protocol}//secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?d=mm&s=30"
  end
end
