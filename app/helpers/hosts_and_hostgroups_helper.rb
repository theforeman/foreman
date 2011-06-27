module HostsAndHostgroupsHelper
  def puppetmaster_field object, f
    puppet_proxies = Feature.find_by_name("Puppet CA").smart_proxies

    # we don't have any puppet proxies, display text box
    return puppetmaster_text_field(object, f) if puppet_proxies.empty?
    # we need the let the user chose a proxy or a select box
    # if we have a proxy, we'll default to a select box
    content_tag(:span) do
      toggle_puppetmaster_field(object) + puppetmaster_select_proxy(object, f, puppet_proxies) + puppetmaster_text_field(object, f)
    end
  end

  def puppetmaster_text_field object, f
    content_tag(:span, :id => "display_name", :style => display(object.puppetca? || object.new_record?)) do
      f.label(:puppetmaster_name, "Puppetmaster") +
      f.text_field(:puppetmaster_name, :size => 8, :value => object.puppetmaster)
    end
  end

  def puppetmaster_select_proxy object, f, proxies
    content_tag(:span, :id => "display_proxy", :style => display(!(object.puppetca? || object.new_record?))) do
      f.label(:puppetproxy_id, "Puppetmaster") +
      f.collection_select(:puppetproxy_id, proxies, :id, :name, :include_blank => true)
    end
  end

  def toggle_puppetmaster_field object
    link_to_function(image_tag("link.png"), :id => "switcher", :title => "Switch to using a reference to a smart proxy") do |page|
      page << "if ($('#display_proxy').is(':visible')) {"
      page["#{object.class.to_s.downcase}_puppetproxy_id"].value = ""
      page << "}"
      page << "if ($('display_name').is(':visible')) {"
      page["#{object.class.to_s.downcase}_puppetmaster_name"].value = ""
      page << "}"
      page[:display_name].toggle
      page[:display_proxy].toggle
    end
  end

  def hostgroup_name group
    return if group.blank?
    content_tag(:span, group.to_s.gsub(group.name, ""), :class => "grey") +
      link_to_if_authorized(h(group.name), hash_for_edit_hostgroup_path(:id => group))
  end

  def accessible_hostgroups
    hg = (User.current.hostgroups.any? and !User.current.admin?) ? User.current.hostgroups : Hostgroup.all
    hg.sort
  end

  def image_file_entry item
    # If the host has an explicit image_path then use that
    # Else use the default based upon the host's medium and operatingsystem
    value = item.image_file || item.default_image_file
    text_field :item, :image_file, :value => value, :disabled => !item.use_image,
                 :id => type + "_image_file", :name => type + "[image_file]", :class => "span-14 last"
  end

  def parent_classes obj
    return obj.hostgroup.classes if obj.is_a?(Host) and obj.hostgroup
    return obj.is_root? ? [] : obj.parent.classes if obj.is_a?(Hostgroup)
    []
  end

end
