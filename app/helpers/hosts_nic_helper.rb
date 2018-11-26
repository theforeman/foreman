module HostsNicHelper
  def suggest_new_link(form, field, link_class)
    subnet = form.object.public_send(field)
    show = subnet.present? && subnet.unused_ip.suggest_new?
    link_class += " hide" unless show
    link_to(_("Suggest new"), '#', :class => link_class)
  end

  def accessible_subnets_for_select(obj, resource)
    accessible_resource_for_select(obj, resource, columns: [:id, :name, :vlanid])
  end

  def nic_subnet_field(f, attr, klass, html_options = {})
    subnets = accessible_subnets_for_select(f.object, klass)
    html_options.merge!(
      { :disabled => subnets.empty?,
        :help_inline => :indicator,
        :'data-url' => freeip_subnets_path,
        :size => "col-md-8", :label_size => "col-md-3" }
    )
    if subnets.any?
      array = options_for_select(
        [[]] +
        subnets.map { |subnet| [subnet[1], subnet[0], {'data-suggest_new' => false, 'data-vlan_id' => subnet[2]}]}, f.object.public_send(attr)
      )
    else
      array = [[_("No subnets"), '']]
    end
    selectable_f f, attr, array, {}, html_options
  end
end
