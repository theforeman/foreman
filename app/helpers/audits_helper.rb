module AuditsHelper
  MAIN_OBJECTS = %w(Host::Base Hostgroup User Operatingsystem Environment Puppetclass Parameter Architecture ComputeResource ProvisioningTemplate ComputeProfile ComputeAttribute
                    Location Organization Domain Subnet SmartProxy AuthSource Image Role Usergroup Bookmark ConfigGroup Ptable ReportTemplate)

  # lookup the Model representing the numerical id and return its label
  def id_to_label(name, change, truncate = true)
    return _("N/A") if change.nil?
    case name
      when "ancestry"
        label = change.blank? ? "" : change.split('/').map { |i| Hostgroup.find(i).name rescue _("NA") }.join('/')
      when 'last_login_on'
        label = change.to_s(:short)
      when /.*_id$/
        begin
          label = key_to_class(name)&.find(change)&.to_label
        rescue NameError
          # fallback to the value only instead of N/A that is in generic rescue below
          return _("Missing(ID: %s)") % change
        end
      when /.*_ids$/
        existing = key_to_class(name)&.where(id: change)&.index_by(&:id)
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
        (id_to_label audit.audited_changes.keys[0], audit.audited_changes.values[0]).to_s
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

  def details(audit, path = audit_path(audit))
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
          _("%{name} changed from %{label1} to %{label2}") % { :name => name.humanize, :label1 => id_to_label(name, change[0]), :label2 => id_to_label(name, change[1]) }
        end
      end
    elsif !main_object? audit
      ["#{audit_action_name(audit).humanize} #{id_to_label audit.audited_changes.keys[0], audit.audited_changes.values[0]}
       #{(audit_action_name(audit) == 'removed') ? 'from' : 'to'} #{audit.associated_name || id_to_label(audit.audited_changes.keys[1], audit.audited_changes.values[1])}"]
    else
      []
    end
  end

  def audit_template?(audit)
    audit.audited_changes["template"] && audit.audited_changes["template"][0] != audit.audited_changes["template"][1]
  end

  def audit_login?(audit)
    name = audit.audited_changes.keys[0] rescue ''
    name == 'last_login_on'
  end

  def audit_action_name(audit)
    return (audit.action == 'destroy') ? 'destroyed' : "#{audit.action}d" if main_object? audit

    case audit.action
      when 'create'
        'added'
      when 'destroy'
        'removed'
      else
        'updated'
    end
  end

  def audit_user(audit)
    return if audit.username.nil?
    login = audit.user.login rescue nil # aliasing the user method sometimes yields strings
    link_to(icon_text('user', audit.username.gsub(_('User'), '')), hash_for_audits_path(:search => login ? "user = #{login}" : "username = \"#{audit.username}\""))
  end

  def audit_time(audit)
    date_time_absolute(audit.created_at)
  end

  def audit_affected_locations(audit)
    base = audit.locations.authorized(:view_locations)
    return _('N/A') if base.empty?

    authorizer = Authorizer.new(User.current, base)
    base.map do |location|
      link_to_if_authorized location.name, hash_for_edit_location_path(location).merge(:auth_object => location, :permission => 'edit_locations', :authorizer => authorizer)
    end.to_sentence.html_safe
  end

  def audit_affected_organizations(audit)
    base = audit.organizations.authorized(:view_organizations)
    return _('N/A') if base.empty?

    authorizer = Authorizer.new(User.current, base)
    base.map do |organization|
      link_to_if_authorized organization.name, hash_for_edit_organization_path(organization).merge(:auth_object => organization, :permission => 'edit_organizations', :authorizer => authorizer)
    end.to_sentence.html_safe
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
                  when 'LookupKey', 'VariableLookupKey'
                    'Smart Variable'
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
    content_tag :span, :style => 'color:#999;' do
      "(" + audit.remote_address + ")"
    end
  end

  def audit_details(audit)
    "#{audit_user(audit)} #{audit_remote_address audit} #{audit_action_name audit} #{audited_type audit}: #{link_to(audit_title(audit), audit_path(audit))}".html_safe
  end

  def nested_host_audit_breadcrumbs
    return unless @host

    breadcrumbs(
      switchable: false,
      items: [
        {
          caption: _("Hosts"),
          url: (url_for(hosts_path) if authorized_for(hash_for_hosts_path))
        },
        {
          caption: @host.name,
          url: (host_path(@host) if authorized_for(hash_for_host_path(@host)))
        },
        {
          caption: _('Audits'),
          url: url_for(audits_path)
        }
      ]
    )
  end

  private

  def main_object?(audit)
    return true if MAIN_OBJECTS.include?(audit.auditable_type)
    type = audit.auditable_type.split("::").last rescue ''
    MAIN_OBJECTS.include?(type)
  end

  def key_to_class(key)
    @audit.auditable_type.constantize.reflect_on_association(key.sub(/_id(s?)$/, '\1'))&.klass
  end
end
