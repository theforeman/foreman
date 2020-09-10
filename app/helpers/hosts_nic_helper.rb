module HostsNicHelper
  def suggest_new_link(form, field, link_class)
    subnet = form.object.public_send(field)
    show = subnet.present? && subnet.unused_ip.suggest_new?
    link_class += " hide" unless show
    link_to(_("Suggest new"), '#', :class => link_class)
  end

  def nic_subnet_field(f, attr, klass, html_options = {})
    html_options.merge!(
      { :disabled => accessible_resource(f.object, klass).empty? ? true : false,
        :help_inline => :indicator,
        :'data-url' => freeip_subnets_path,
        :size => "col-md-8", :label_size => "col-md-3" }
    )
    if accessible_resource(f.object, klass).any?
      array = options_for_select(
        [[]] +
        accessible_resource(f.object, klass).map { |subnet| [subnet.to_label, subnet.id, {'data-suggest_new' => subnet.unused_ip.suggest_new?, 'data-vlan_id' => subnet.vlanid}] }, f.object.public_send(attr)
      )
    else
      array = [[_("No subnets"), '']]
    end
    selectable_f f, attr, array, {}, html_options
  end
end
