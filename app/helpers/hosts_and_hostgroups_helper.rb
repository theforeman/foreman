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
    content_tag(:span, :id => "display_name", :style => display(object.puppetca?)) do
      f.label(:puppetmaster_name, "Puppetmaster") +
      f.text_field(:puppetmaster_name, :size => 8, :value => object.puppetmaster)
    end
  end

  def puppetmaster_select_proxy object, f, proxies
    content_tag(:span, :id => "display_proxy", :style => display(!object.puppetca?)) do
      f.label(:puppetproxy_id, "Puppetmaster") +
      f.collection_select(:puppetproxy_id, proxies, :id, :name, :include_blank => true)
    end
  end

  def toggle_puppetmaster_field object
    link_to_function(image_tag("link.png"), :id => "switcher", :title => "Switch to using a reference to a smart proxy") do |page|
      page << "if ($('display_proxy').visible()) {"
      page["#{object.class.to_s.downcase}_puppetproxy_id"].value = ""
      page << "}"
      page << "if ($('display_name').visible()) {"
      page["#{object.class.to_s.downcase}_puppetmaster_name"].value = ""
      page << "}"
      page[:display_name].toggle
      page[:display_proxy].toggle
    end
  end

end
