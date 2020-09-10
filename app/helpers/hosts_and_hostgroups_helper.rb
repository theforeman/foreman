module HostsAndHostgroupsHelper
  include AncestryHelper

  def domain_subnets(type)
    accessible_related_resource(@domain, :subnets, :where => {:type => type})
  end

  def arch_oss
    accessible_related_resource(@architecture, :operatingsystems, order: :title)
  end

  def os_media
    accessible_related_resource(@operatingsystem, :media)
  end

  def os_ptable
    accessible_related_resource(@operatingsystem, :ptables)
  end

  def visible_compute_profiles(obj)
    (ComputeProfile.authorized(:view_compute_profiles).visibles.to_a | [obj.compute_profile]).compact
  end

  INHERIT_TEXT = N_("inherit")

  def realm_field(f, can_override = false, override = false)
    # Don't show this if we have no Realms, otherwise always include blank
    # so the user can choose not to use a Realm on this host
    return unless (SETTINGS[:unattended] == true) && @host.managed
    realms = accessible_resource(f.object, :realm)
    return unless realms.present?
    select_f(f, :realm_id,
      realms,
      :id, :to_label,
      { :include_blank => true,
        :disable_button => can_override ? _(INHERIT_TEXT) : nil,
        :disable_button_enabled => override && !explicit_value?(:realm_id),
        :user_set => user_set?(:realm_id),
      },
      { :help_inline => :indicator }
    ).html_safe
  end

  def multiple_filter(hosts)
    return unless multiple_with_filter?
    host_count = hosts.size
    no_filter = n_("Reminder: <strong> One host is selected </strong>",
      "Reminder: <strong> All %{count} hosts are selected </strong>", host_count).html_safe % {count: host_count}
    with_filter = n_("Reminder: <strong> One host is selected </strong> for query filter %{query}",
      "Reminder: <strong> All %{count} hosts are selected </strong> for query filter %{query}", host_count).html_safe % {count: host_count, query: h(params[:search]) }
    params[:search].blank? ? no_filter : with_filter
  end
end
