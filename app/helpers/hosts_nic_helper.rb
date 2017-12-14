module HostsNicHelper
  def suggest_new_link(form, field, link_class)
    subnet = form.object.public_send(field)
    show = subnet.present? && subnet.unused_ip.suggest_new?
    link_class += " hide" unless show
    link_to(_("Suggest new"), '#', :class => link_class)
  end

  def accessible_subnets_for_select(obj, resource)
    fields = [:id, :name, :vlanid]
    subnets = accessible_resource(obj, resource).pluck(*fields)
    subnets.map { |subnet| fields.zip(subnet).to_h }
  end

  def nic_subnet_field(f, attr, klass, html_options = {})
    # TODO: suggest_new?
    # TODO: label
    subnets = accessible_subnets_for_select(f.object, klass)
    html_options.merge!(
      { :disabled => subnets.empty? ? true : false,
        :help_inline => :indicator,
        :'data-url' => freeip_subnets_path,
        :size => "col-md-8", :label_size => "col-md-3" }
    )
    if subnets.any?
      array = options_for_select(
        [[]] +
        subnets.map{ |subnet| [subnet[:name], subnet[:id], {'data-suggest_new' => false, 'data-vlan_id' => subnet[:vlanid]}]}, f.object.public_send(attr)
      )
    else
      array = [[_("No subnets"), '']]
    end
    selectable_f f, attr, array, {}, html_options
  end
end
