module HomeHelper

  def class_for_current_page(tab)
    controller_name.gsub(/_.*/,"s") == tab ? "active" : ""
  end

  def class_for_setting_page
   if setting_options.map{|o| o[1]}.include? controller_name.to_sym
     "active"
   end
  end

  def setting_options
    choices = [
      ['Bookmarks',              :bookmarks],
      ['Environments',           :environments],
      ['Settings',               :settings],
      ['Global Parameters',      :common_parameters],
      ['Host Groups',            :hostgroups],
      ['Puppet Classes',         :puppetclasses],
      ['Smart Variables',        :lookup_keys],
      ['Smart Proxies',          :smart_proxies]
    ]

    choices += [
      ['Architectures',          :architectures],
      ['Domains',                :domains],
      ['Hardware Models',        :models],
      ['Installation Media',     :media],
      ['Operating Systems',      :operatingsystems],
      ['Partition Tables',       :ptables],
      ['Provisioning Templates', :config_templates],
      ['Subnets',                :subnets]
    ] if SETTINGS[:unattended]

    choices += [
      ['Users',                  :users],
      ['User Groups',            :usergroups],
      ['LDAP Authentication',    :auth_source_ldaps]
    ] if SETTINGS[:login]
    choices += [
      ['Roles',                  :roles]
    ] if SETTINGS[:login] and User.current.admin?
    choices += [['Hypervisors',  :hypervisors]] if SETTINGS[:libvirt]

    choices.sort
  end


  def menu(tab, myBookmarks ,path = nil)
    path ||= eval("hash_for_#{tab}_path")
    return '' unless authorized_for(path[:controller], path[:action] )
    b = myBookmarks.map{|b| b if b.controller == path[:controller]}.compact
    out = content_tag :li, :class => class_for_current_page(tab) do
      link_to_if_authorized(tab.capitalize, path, :class => b.empty? ? "" : "narrow-right")
    end
    out +=  content_tag :li, :class => "dropdown " + class_for_current_page(tab) do
      link_to("", "#", :class => "dropdown-toggle narrow-left") + menu_dropdown(b)
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
end
