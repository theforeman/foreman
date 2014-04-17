module AuditsHelper

  MainObjects = %w(Host Hostgroup User Operatingsystem Environment Puppetclass Parameter Architecture ComputeResource ConfigTemplate ComputeProfile ComputeAttribute
                   Location Organization Domain Subnet SmartProxy AuthSource Image Role Usergroup Bookmark ConfigGroup)

  # lookup the Model representing the numerical id and return its label
  def id_to_label name, change
    return _("N/A") if change.nil?
    case name
      when "ancestry"
        change.blank? ? "" : change.split('/').map { |i| Hostgroup.find(i).name rescue _("NA") }.join('/')
      when 'last_login_on'
        change.to_s(:short)
      when /.*_id$/
        name.classify.gsub('Id','').constantize.find(change).to_label
      else
        change.to_s
    end.truncate(50)
  rescue
    _("N/A")
  end

  def audit_title audit
    type_name = audited_type audit
    case type_name
      when 'Puppet Class'
        "#{id_to_label audit.audited_changes.keys[0], audit.audited_changes.values[0]}"
      else
        name = audit.auditable_name.blank? ? audit.revision.to_label : audit.auditable_name
        name += " / #{audit.associated_name}" if audit.associated_id and !audit.associated_name.blank?
        name
    end
  rescue
    ""
  end

  def details audit
    if audit.action == 'update'
      Array.wrap(audit.audited_changes).map do |name, change|
        next if change.nil? or change.to_s.empty?
        if name == 'template'
          (_("Provisioning Template content changed %s") % (link_to 'view diff', audit_path(audit))).html_safe if audit_template? audit
        elsif name == "owner_id" || name == "owner_type"
          _("Owner changed to %s") % (audit.revision.owner rescue _('N/A'))
        else
          _("%{name} changed from %{label1} to %{label2}") % { :name => name.humanize, :label1 => id_to_label(name, change[0]), :label2 => id_to_label(name, change[1]) }
        end
      end
    elsif !main_object? audit
      ["#{audit_action_name(audit).humanize} #{id_to_label audit.audited_changes.keys[0], audit.audited_changes.values[0]}
       #{audit_action_name(audit)=="removed" ? "from" : "to"} #{audit.associated_name || id_to_label(audit.audited_changes.keys[1], audit.audited_changes.values[1])}"]
    else
      []
    end
  end

  def audit_template? audit
    audit.auditable_type == "ConfigTemplate" && audit.action == 'update' && audit.audited_changes["template"] &&
      audit.audited_changes["template"][0] != audit.audited_changes["template"][1]
  end

  def audit_login? audit
    name = audit.audited_changes.keys[0] rescue ''
    name == 'last_login_on'
  end

  def audit_action_name audit
    return audit.action == 'destroy' ? 'destroyed' : "#{audit.action}d" if main_object? audit

    case audit.action
      when 'create'
        'added'
      when 'destroy'
        'removed'
      else
        'updated'
    end
  end

  def audit_user audit
    return if audit.username.nil?
    login = audit.user.login rescue nil # aliasing the user method sometimes yields strings
    link_to(icon_text('user', audit.username.gsub(_('User'), '')), hash_for_audits_path(:search => login ? "user = #{login}" : "username = \"#{audit.username}\""))
  end

  def audit_time audit
    content_tag :span, _("%s ago") % time_ago_in_words(audit.created_at),
                { :'data-original-title' => audit.created_at.to_s(:long), :rel => 'twipsy' }
  end

  def audited_icon audit
    style = 'label-info'
    style = case audit.action
              when 'create'
                'label-success'
              when 'update'
                'label-info'
              when 'destroy'
                'label-danger'
              else
                ''
            end if main_object? audit
    style += " label"

    type   = audited_type(audit)
    symbol = case type
               when "Host"
                 'hdd'
               when "Hostgroup"
                 'tasks'
               when "User"
                 'user'
               else
                 'cog'
             end
    content_tag(:b, icon_text(symbol, type, :class => 'icon-white'), :class => style)
  end

  def audited_type audit
    type_name = case audit.auditable_type
                  when 'HostClass'
                    'Puppet Class'
                  when 'Parameter'
                    "#{audit.associated_type || 'Global'}-#{type_name}"
                  when 'LookupKey'
                    'Smart Variable'
                  when 'LookupValue'
                    'Override Value'
                  else
                    audit.auditable_type
                end
    type_name.underscore.titleize
  end

  def audit_remote_address audit
    return if audit.remote_address.empty?
    content_tag :span, :style => 'color:#999;' do
      "(" + audit.remote_address + ")"
    end
  end

  private
  def main_object? audit
    type = audit.auditable_type.split("::").last rescue ''
    MainObjects.include?(type)
  end

end
