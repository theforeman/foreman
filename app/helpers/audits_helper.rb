module AuditsHelper
  AUDIT_ADD = 'add'
  AUDIT_REMOVE = 'remove'

  # lookup the Model representing the numerical id and return its label
  def id_to_label(name, change, audit: @audit, truncate: true)
    return _("N/A") if change.nil?
    case name
      when "ancestry"
        label = change.blank? ? "" : change.split('/').map { |i| Hostgroup.find(i).name rescue _("NA") }.join('/')
      when 'last_login_on'
        label = change.to_s(:short)
      when /.*_id$/
        begin
          label = find_associated_records_using_key(name, change, audit)&.to_label
        rescue NameError
          # fallback to the value only instead of N/A that is in generic rescue below
          return _("Missing(ID: %s)") % change
        end
      when /.*_ids$/
        existing = find_associated_records_using_key(name, change, audit)
        label = change.map do |id|
          if existing&.has_key?(id)
            existing[id].to_label
          else
            _("Missing(ID: %s)") % id
          end
        end.join(', ')
      else
        label = (change.to_s == AuditExtensions::REDACTED) ? _(change.to_s) : change.to_s
    end
    label = _('[empty]') unless label.present?
    if truncate
      label = label.truncate(50)
    else
      label = label.strip.split("\n")[0]
    end
    label
  rescue
    _("N/A")
  end

  def audit_title(audit)
    type_name = audited_type audit
    case type_name
      when 'Puppet Class'
        (id_to_label audit.audited_changes.keys[0], audit.audited_changes.values[0], audit: audit).to_s
      else
        name = if audit.auditable_name.blank?
                 revision = audit.revision
                 (revision.respond_to?(:to_audit_label) && revision.to_audit_label) || revision.to_label
               else
                 audit.auditable_name
               end
        name += " / #{audit.associated_name}" if audit.associated_id && audit.associated_name.present? && type_name != 'Interface'
        name
    end
  rescue StandardError => exception
    Foreman::Logging.exception("Could not render audit_title", exception)
    ""
  end

  def details(audit, path = audits_path(:search => "id=#{audit.id}"))
    if audit.action == 'update'
      return [] unless audit.audited_changes.present?
      audit.audited_changes.map do |name, change|
        next if change.nil? || change.to_s.empty?
        if name == 'template'
          (_("Template content changed %s") % (link_to 'view diff', path)).html_safe if audit_template? audit
        elsif name == "password_changed"
          _("Password has been changed")
        elsif name == "owner_id" || name == "owner_type"
          _("Owner changed to %s") % (audit.revision.owner rescue _('N/A'))
        elsif name == 'global_status'
          base = audit.audited_changes.values[0]
          from = HostStatus::Global.new(base[0]).to_label
          to = HostStatus::Global.new(base[1]).to_label
          _("Global status changed from %{from} to %{to}") % { :from => from, :to => to }
        else
          _("%{name} changed from %{label1} to %{label2}") % {
            :name => name.humanize,
            :label1 => id_to_label(name, change[0], audit: audit),
            :label2 => id_to_label(name, change[1], audit: audit) }
        end
      end
    elsif !main_object? audit
      from = id_to_label(audit.audited_changes.keys[0], audit.audited_changes.values[0], audit: audit)
      to = audit.associated_name || id_to_label(audit.audited_changes.keys[1], audit.audited_changes.values[1], audit: audit)
      case audit_action_name(audit)
      when AUDIT_ADD
        [_("Added %{from} to %{to}") % {:from => from, :to => to}]
      when AUDIT_REMOVE
        [_("Removed %{from} to %{to}") % {:from => from, :to => to}]
      end
    else
      []
    end
  end

  def audit_template?(audit)
    return false if audit.audited_changes.blank?
    audit.audited_changes["template"] && audit.audited_changes["template"][0] != audit.audited_changes["template"][1]
  end

  def audit_login?(audit)
    name = audit.audited_changes.keys[0] rescue ''
    name == 'last_login_on'
  end

  def audit_action_name(audit)
    return audit.action if main_object? audit

    case audit.action
      when 'create'
        AUDIT_ADD
      when 'destroy'
        AUDIT_REMOVE
      else
        'update'
    end
  end

  def audit_user(audit)
    return if audit.username.nil?
    login = audit.user_login
    link_to(icon_text('user', audit.username.gsub(_('User'), '')), hash_for_audits_path(:search => login ? "user = #{login}" : "username = \"#{audit.username}\""))
  end

  def audit_time(audit)
    date_time_absolute(audit.created_at)
  end

  def audited_icon(audit)
    style = 'label-info'
    if main_object? audit
      style = case audit.action
                when 'create'
                  'label-success'
                when 'update'
                  'label-info'
                when 'destroy'
                  'label-danger'
                else
                  ''
              end
    end
    style += " label"

    type   = audited_type(audit)
    symbol = case type
               when "Host"
                 {:icon => 'server', :kind => 'pficon'}
               when "Hostgroup"
                 {:icon => 'server-group', :kind => 'pficon'}
               when 'Interface'
                 {:icon => 'network', :kind => 'pficon'}
               when "User"
                 {:icon => 'user', :kind => 'fa'}
               else
                 {:icon => 'cog', :kind => 'fa'}
             end
    content_tag(:b, icon_text(symbol[:icon], type, :class => 'icon-white', :kind => symbol[:kind]), :class => style)
  end

  def audited_type(audit)
    type_name = case audit.auditable_type
                  when 'Host::Base'
                    'Host'
                  when 'HostClass'
                    'Puppet Class'
                  when 'Parameter'
                    "#{audit.associated_type || 'Global'}-#{type_name}"
                  when 'PuppetclassLookupKey'
                    'Smart Class Parameter'
                  when 'LookupValue'
                    'Override Value'
                  when 'Ptable'
                    'Partition Table'
                  when /^Nic/
                    'Interface'
                  else
                    audit.auditable_type
                end
    type_name.underscore.titleize
  end

  def audit_remote_address(audit)
    return if audit.remote_address.empty?
    content_tag :p, :style => 'color:#999;' do
      "(" + audit.remote_address + ")"
    end
  end

  def nested_host_audit_breadcrumbs
    return unless @host

    breadcrumbs(
      switchable: false,
      items: [
        {
          caption: _("Hosts"),
          url: (hosts_path if authorized_for(hash_for_hosts_path)),
        },
        {
          caption: @host.name,
          url: (current_host_details_path(@host) if authorized_for(hash_for_host_path(@host))),
        },
        {
          caption: _('Audits'),
          url: audits_path,
        },
      ]
    )
  end

  def construct_additional_info(audits)
    audits.map do |audit|
      action_display_name = audit_action_name(audit)

      audit.attributes.merge!(
        'action_display_name' => action_display_name,
        'audited_type_name' => audited_type(audit),
        'user_info' =>  user_info(audit),
        'audit_title' => audit_title(audit),
        'audit_title_url' => audit_title_url(audit),
        'affected_locations' => fetch_affected_locations(audit),
        'affected_organizations' => fetch_affected_organizations(audit),
        'details' => additional_details_if_any(audit, action_display_name),
        'audited_changes_with_id_to_label' => audit.audited_changes.blank? ? [] : rebuild_audit_changes(audit),
        'allowed_actions' => actions_allowed(audit)
      )
    end
  end

  private

  def additional_details_if_any(audit, action_display_name)
    [AUDIT_ADD, AUDIT_REMOVE].include?(action_display_name) ? details(audit) : []
  end

  def main_object?(audit)
    main_objects_names = Audit.main_object_names
    return true if main_objects_names.include?(audit.auditable_type)
    type = audit.auditable_type.split("::").last rescue ''
    main_objects_names.include?(type)
  end

  def find_auditable_type_class(audit)
    auditable_type = (audit.auditable_type == 'Host::Base') ? 'Host::Managed' : audit.auditable_type
    auditable_type.constantize
  end

  def key_to_association_class(key, auditable_class)
    association_name = key.gsub(/_id(s?)$/, '')
    association_name = association_name.pluralize if key =~ /_ids$/
    reflection_obj = auditable_class.reflect_on_association(association_name)
    reflection_obj ? reflection_obj&.klass : nil
  end

  def find_associated_records_using_key(key, change, audit)
    auditable_class = find_auditable_type_class(audit)
    association_class = key_to_association_class(key, auditable_class)

    if association_class
      if key =~ /_ids$/
        association_class&.where(id: change)&.index_by(&:id)
      elsif key =~ /_id$/
        association_class&.find(change)
      end
    elsif auditable_class.respond_to?('audit_hook_to_find_records')
      auditable_class.audit_hook_to_find_records(key, change, audit)
    end
  end

  def rebuild_audit_changes(audit)
    css_class_name = css_class_by_action(audit.action == 'destroy')
    # update data for created template for better view
    if audit.action == 'create' && (change = audit.audited_changes['template']).present?
      audit.audited_changes['template'] = ['', change]
    end
    audit.audited_changes.map do |name, change|
      next if change.nil? || change.to_s.empty?
      next if name == 'template'
      rec = { :name => name.humanize }
      if audit.action == 'update'
        rec[:change] = change.map.with_index do |v, i|
          change_info_hash(name, v, css_class_by_action(i == 0), audit: audit)
        end
      else
        rec[:change] = (rec[:change] || []).push(change_info_hash(name, change, css_class_name, audit: audit))
      end
      rec
    end.compact
  end

  def css_class_by_action(is_condition_match)
    is_condition_match ? 'show-old' : 'show-new'
  end

  def change_info_hash(name, change, css_class = 'show-new', audit: nil)
    { :css_class => css_class, :id_to_label => id_to_label(name, change, truncate: false, audit: audit) }
  end

  def fetch_affected_locations(audit)
    base = (audit.locations.authorized(:view_locations) + (audit.locations & User.current.my_locations)).uniq
    return [] if base.empty?

    authorizer = Authorizer.new(User.current, base)
    base.map do |location|
      options = hash_for_edit_location_path(location).merge(:auth_object => location, :permission => 'edit_locations', :authorizer => authorizer)
      construct_options(location.name, edit_location_path(location), options)
    end
  end

  def fetch_affected_organizations(audit)
    base = (audit.organizations.authorized(:view_organizations) + (audit.organizations & User.current.my_organizations)).uniq
    return [] if base.empty?

    authorizer = Authorizer.new(User.current, base)
    base.map do |organization|
      options = hash_for_edit_organization_path(organization).merge(:auth_object => organization, :permission => 'edit_organizations', :authorizer => authorizer)
      construct_options(organization.name, edit_organization_path(organization), options)
    end
  end

  def construct_options(affected_obj_name, affected_obj_url, options = {})
    if authorized_for(options)
      {'name' => affected_obj_name, 'url' => affected_obj_url}
    else
      {'name' => affected_obj_name, 'url' => '#', 'css_class' => "disabled", 'disabled' => true}
    end
  end

  def audit_title_url(audit)
    keytype_array = Audit.find_complete_keytype_array(audit.auditable_type)
    filter = "type = #{keytype_array.first} and auditable_id = #{audit.auditable_id}" if keytype_array.present?
    (filter ? audits_path(:search => filter) : nil)
  end

  def user_info(audit)
    return {} if audit.username.nil?
    login = audit.user_login
    {
      'display_name' => audit.username.gsub(_('User'), ''),
      'login' => login,
      'search_path' => audits_path(:search => login ? "user = #{login}" : "username = \"#{audit.username}\""),
      'audit_path' => audits_path(:search => "id=#{audit.id}"),
    }
  end

  def actions_allowed(audit)
    actions = []
    if audit.auditable_type == 'Host::Base' && audit.auditable
      actions.push(host_details_action(audit.auditable))
    end
    if audit.auditable_type.match(/^Nic/) && audit.associated_type == 'Host::Base' && audit.associated
      actions.push(host_details_action(audit.associated, :is_associated => true))
    end
    actions
  end

  def host_details_action(host, options = {})
    host_path_name = find_host_path_name(host)
    action_details = { :title => _("Host details"), :css_class => 'btn btn-default' }
    action_details[:name] = _("Associated Host") if options[:is_associated]
    auth_options = send("hash_for_#{host_path_name}", :id => host.to_param).merge(
      :auth_object => host, :auth_action => 'view')
    if authorized_for(auth_options)
      action_details[:url] = current_host_details_path(host)
    else
      action_details.merge!(:url => '#', :css_class => 'btn btn-default disabled', :disabled => true)
    end
    action_details
  end

  def find_host_path_name(host)
    host_type = host.type
    default_path = 'host_path'
    return default_path if ['Host::Base', 'Host::Managed'].include?(host_type)
    host_path_name = host_type.split('::').last.downcase + "_#{default_path}"
    respond_to?(host_path_name) ? host_path_name : default_path
  end
end
