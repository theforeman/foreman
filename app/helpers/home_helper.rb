module HomeHelper

  def class_for_current_page(tab)
    controller_name.gsub(/_.*/,"s") == tab ? "active" : ""
  end

  def show_organization_tab?
    SETTINGS[:multi_org] or (SETTINGS[:orgs_enabled] && (User.current.admin? || authorized_for(:organizations, :index)))
  end

  def class_for_setting_page
   if setting_options.map{|o| o[1]}.include? controller_name.to_sym
     "active"
   end
  end

  def setting_options
    choices = [
      ['Environments',           :environments],
      ['Global Parameters',      :common_parameters],
      ['Host Groups',            :hostgroups],
      ['Puppet Classes',         :puppetclasses],
      ['Smart Variables',        :lookup_keys],
      ['Smart Proxies',          :smart_proxies]
    ]

    if SETTINGS[:unattended]
      choices += [
        [:divider],
        ['Compute Resources',    :compute_resources]
      ]

      choices += [ ['Hypervisors', :hypervisors ] ] if SETTINGS[:libvirt]

      choices += [ [:divider] ]
      choices += [ ['Locations',  :locations] ] if show_organization_tab?
      choices += [ ['Resource Groups', :resourcegroups] ]

      choices += [
        ['Architectures',          :architectures],
        ['Domains',                :domains],
        ['Hardware Models',        :models],
        ['Installation Media',     :media],
        ['Operating Systems',      :operatingsystems],
        ['Partition Tables',       :ptables],
        ['Provisioning Templates', :config_templates],
        ['Subnets',                :subnets]
      ]
    end

    choices += [
      [:divider],
      ['LDAP Authentication',    :auth_source_ldaps],
      ['Users',                  :users],
      ['User Groups',            :usergroups],
    ] if SETTINGS[:login]

    choices += [
      ['Roles',                  :roles]
    ] if SETTINGS[:login] and User.current.admin?

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
    out = content_tag :li, :class => class_for_current_page(tab) do
      link_to_if_authorized(tab.capitalize, path, :class => b.empty? ? "" : "narrow-right")
    end
    out +=  content_tag :li, :class => "dropdown hidden-tablet hidden-phone " + class_for_current_page(tab) do
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
end
