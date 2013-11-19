module SystemsHelper
  include OperatingsystemsHelper
  include SystemsAndSystemGroupsHelper
  include ComputeResourcesVmsHelper
  include BmcHelper

  def last_report_column(record)
    time = record.last_report? ? _("%s ago") % time_ago_in_words(record.last_report.getlocal): ""
    link_to_if_authorized(time,
                          hash_for_system_report_path(:system_id => record.to_param, :id => "last"),
                          last_report_tooltip(record))
  end

  def last_report_tooltip record
    opts = { :rel => "twipsy" }
    if @last_reports[record.id]
      opts.merge!( "data-original-title" => _("View last report details"))
    else
      opts.merge!(:disabled => true, :class => "disabled", :onclick => 'return false')
      opts.merge!("data-original-title" => _("Report Already Deleted")) unless record.last_report.nil?
    end
    opts
  end

  # method that reformat the systemname column by adding the status icons
  def name_column(record)
    label = record.system_status
    case label
    when "Pending Installation"
      style ="label-info"
      # TRANSLATORS: system's status: first character of "build"
      short = s_("Build|B")
    when "Alerts disabled"
      style = ""
      # TRANSLATORS: system's status: first character of "disabled"
      short = s_("Disabled|D")
    when "No reports"
      style = ""
      # TRANSLATORS: system's status: first character of "no reports"
      short = s_("No reports|N")
    when "Out of sync"
      style = "label-warning"
      # TRANSLATORS: system's status: first character of "sync" (out of sync)
      short = s_("Sync|S")
    when "Error"
      style = "label-important"
      # TRANSLATORS: system's status: first character of "error"
      short = s_("Error|E")
    when "Active"
      style = "label-info"
      # TRANSLATORS: system's status: first character of "active"
      short = s_("Active|A")
    when "Pending"
      style = "label-warning"
      # TRANSLATORS: system's status: first character of "pending"
      short = s_("Pending|P")
    else
      style = "label-success"
      # TRANSLATORS: system's status: first character of "OK"
      short = s_("OK|O")
    end
    content_tag(:span, short, {:rel => "twipsy", :class => "label label-light " + style, :"data-original-title" => _(label)} ) +
      link_to(trunc("  #{record}",32), system_path(record))
  end

  def days_ago time
    ((Time.now - time) / 1.day).round.to_i
  end

  def authorized?
    authorized_for(:systems, :edit) or authorized_for(:systems, :destroy)
  end

  def searching?
    params[:search].empty?
  end

  def multiple_actions_select
    actions = [
      [_('Change Group'), select_multiple_system_group_systems_path, 'pencil'],
      [_('Change Environment'), select_multiple_environment_systems_path, 'chevron-right'],
      [_('Edit Parameters'), multiple_parameters_systems_path, 'edit'],
      [_('Delete Systems'), multiple_destroy_systems_path, 'trash'],
      [_('Disable Notifications'), multiple_disable_systems_path, 'eye-close'],
      [_('Enable Notifications'), multiple_enable_systems_path, 'bullhorn'],
    ]
    actions.insert(1, [_('Build Systems'), multiple_build_systems_path, 'fast-forward']) if SETTINGS[:unattended]
    actions <<  [_('Run Puppet'), multiple_puppetrun_systems_path, 'play'] if Setting[:puppetrun]
    actions <<  [_('Assign Organization'), select_multiple_organization_systems_path, 'tags'] if SETTINGS[:organizations_enabled]
    actions <<  [_('Assign Location'), select_multiple_location_systems_path, 'map-marker'] if SETTINGS[:locations_enabled]

    content_tag :span, :id => 'submit_multiple' do
      select_action_button( _("Select Action"), actions.map do |action|
        link_to(icon_text(action[2], action[0]) , action[1], :class=>'btn',  :title => _("%s - The following systems are about to be changed") % action[0])
      end.flatten)
    end

  end

  def date ts=nil
    return _("%s ago") % (time_ago_in_words ts) if ts
    _("N/A")
  end

  def template_path opts = {}
    if (t = @system.configTemplate(opts))
      link_to t, edit_config_template_path(t)
    else
      _("N/A")
    end
  end

  def selected? system
    return false if system.nil? or not system.kind_of?(System::Base) or session[:selected].nil?
    session[:selected].include?(system.id.to_s)
  end

  def resources_chart(timerange = 1.day.ago)
    applied, failed, restarted, failed_restarts, skipped = [],[],[],[],[]
    @system.reports.recent(timerange).each do |r|
      applied         << [r.reported_at.to_i*1000, r.applied ]
      failed          << [r.reported_at.to_i*1000, r.failed ]
      restarted       << [r.reported_at.to_i*1000, r.restarted ]
      failed_restarts << [r.reported_at.to_i*1000, r.failed_restarts ]
      skipped         << [r.reported_at.to_i*1000, r.skipped ]
    end
    [{:label=>_("Applied"), :data=>applied,:color =>'#89A54E'},
     {:label=>_("Failed"), :data=>failed,:color =>'#AA4643'},
     {:label=>_("Failed restarts"), :data=>failed_restarts,:color =>'#AA4643'},
     {:label=>_("Skipped"), :data=>skipped,:color =>'#80699B'},
     {:label=>_("Restarted"), :data=>restarted,:color =>'#4572A7'}]
  end

  def runtime_chart(timerange = 1.day.ago)
    config, runtime = [], []
    @system.reports.recent(timerange).each do |r|
      config  << [r.reported_at.to_i*1000, r.config_retrieval]
      runtime << [r.reported_at.to_i*1000, r.runtime]
    end
    [{:label=>_("Config Retrieval"), :data=> config, :color=>'#AA4643'},{:label=>_("Runtime"), :data=> runtime,:color=>'#4572A7'}]
  end

  def reports_show
    return unless @system.reports.size > 0
    form_tag @system, :id => 'days_filter', :method => :get, :class=>"form form-inline" do
      content_tag(:span, (_("Reports from the last %{days} days - %{count} reports found") %
        { :days  => select(nil, 'range', 1..days_ago(@system.reports.first.reported_at),
                    {:selected => @range}, {:class=>"span1", :onchange =>"$('#days_filter').submit();$(this).disabled();"}),
          :count => @system.reports.recent(@range.days.ago).count }).html_safe)
    end
  end

  def name_field system
    return if system.name.blank?
    (SETTINGS[:unattended] and system.managed?) ? system.shortname : system.name
  end

  def show_templates
    unless SETTINGS[:unattended] and @system.managed?
      return content_tag(:div, :class =>"alert") do
        _("Provisioning Support is disabled or this system is not managed")
      end
    end
    begin
      templates = Hash[TemplateKind.order(:name).map do |k|
        template = @system.configTemplate(:kind => k.name)
        next if template.nil?
        [k.name, template]
      end.compact]
    rescue => e
      return case e.to_s
      when "Must provide an operating systems"
        _("Unable to find templates as this system has no operating system")
      else
        e.to_s
      end
    end

    return _("No template found") if templates.empty?
    content_tag :table, :class=>"table table-bordered table-striped" do
      content_tag(:th, _("Template Type")) + content_tag(:th) +
      templates.map do |kind, tmplt|
        content_tag :tr do
          content_tag(:td, _("%s Template") % kind) +
            content_tag(:td,
          link_to_if_authorized(icon_text('pencil'), hash_for_edit_config_template_path(:id => tmplt.to_param), :title => _("Edit"), :rel=>"external") +
          link_to(icon_text('eye-open'), url_for(:controller => '/unattended', :action => kind, :spoof => @system.ip), :title => _("Review"), :"data-provisioning-template" => true ))
        end
      end.join(" ").html_safe
    end
  end

  def overview_fields system
    fields = [
      [_("Domain"), (link_to(system.domain, systems_path(:search => "domain = #{system.domain}")) if system.domain)],
      [_("IP Address"), system.ip],
      [_("MAC Address"), system.mac],
      [_("Puppet Environment"), (link_to(system.environment, systems_path(:search => "environment = #{system.environment}")) if system.environment)],
      [_("System Architecture"), (link_to(system.arch, systems_path(:search => "architecture = #{system.arch}")) if system.arch)],
      [_("Operating System"), (link_to(system.os, systems_path(:search => "os = #{system.os.name}")) if system.os)],
      [_("System group"), (link_to(system.system_group, systems_path(:search => %Q{system_group_fullname = "#{system.system_group}"})) if system.system_group)],
    ]
    fields += [[_("Location"), (link_to(system.location.name, systems_path(:search => "location = #{system.location}")) if system.location)]] if SETTINGS[:locations_enabled]
    fields += [[_("Organization"), (link_to(system.organization.name, systems_path(:search => "organization = #{system.organization}")) if system.organization)]] if SETTINGS[:organizations_enabled]
    if SETTINGS[:login]
      if system.owner_type == _("User")
        fields += [[_("Owner"), (link_to(system.owner, systems_path(:search => "user.login = #{system.owner.login}")) if system.owner)]]
      else
        fields += [[_("Owner"), system.owner]]
      end
    end
    fields += [[_("Certificate Name"), system.certname]] if Setting[:use_uuid_for_certificates]
    fields
  end

  def possible_images cr, arch = nil, os = nil
    return cr.images unless controller_name == "systems"
    return [] unless arch && os
    cr.images.where(:architecture_id => arch, :operatingsystem_id => os)
  end

  def state s
    s ? ' ' + _("Off") : ' ' + _("On")
  end

  def system_title_actions(system, vm)
    title_actions(
        button_group(
            link_to_if_authorized(_("Edit"), hash_for_edit_system_path(:id => system), :title => _("Edit your system")),
            if system.build
              link_to_if_authorized(_("Cancel Build"), hash_for_cancelBuild_system_path(:id => system), :disabled => system.can_be_built?,
                                    :title                                                                 => _("Cancel build request for this system"))
            else
              link_to_if_authorized(_("Build"), hash_for_setBuild_system_path(:id => system), :disabled => !system.can_be_built?,
                                    :title                                                       => _("Enable rebuild on next system boot"),
                                    :confirm                                                     => _("Rebuild %s on next reboot?\nThis would also delete all of its current facts and reports") % system)
            end
        ),
        if system.compute_resource_id
          button_group(
              if vm
                html_opts = vm.ready? ? {:confirm => _('Are you sure?'), :class => "btn btn-danger"} : {:class => "btn btn-success"}
                link_to_if_authorized _("Power%s") % state(vm.ready?), hash_for_power_system_path(:power_action => vm.ready? ? :stop : :start), html_opts.merge(:method => :put)
              else
                link_to(_("Unknown Power State"), '#', :disabled => true, :class => "btn btn-warning")
              end +
                  link_to_if_authorized(_("Console"), hash_for_console_system_path(), {:disabled => vm.nil? || !vm.ready?, :class => "btn btn-info"})
          )
        end,
        button_group(
          if system.try(:puppet_proxy)
            link_to_if_authorized(_("Run puppet"), hash_for_puppetrun_system_path(:id => system).merge(:auth_action => :edit),
                                  :disabled => !Setting[:puppetrun],
                                  :title => _("Trigger a puppetrun on a node; requires that puppet run is enabled"))
          end
        ),
        button_group(
            link_to_if_authorized(_("Delete"), hash_for_system_path(:id => system, :auth_action => :destroy),
                                  :class => "btn btn-danger", :confirm => _('Are you sure?'), :method => :delete)
        )
    )
  end

  def conflict_objects errors
    errors.keys.map(&:to_s).grep(/conflict$/).map(&:to_sym)
  end

  def has_conflicts? errors
    conflict_objects(errors).each do |c|
      return true if errors[c.to_sym].any?
    end
    false
  end

  def args_for_compute_resource_partial(system)
    { :arch => system.try(:architecture_id)    || (params[:system] && params[:system][:architecture_id]),
      :os   => system.try(:operatingsystem_id) || (params[:system] && params[:system][:operatingsystem_id])
    }
  end

  def show_appropriate_system_buttons(system)
    [ link_to_if_authorized(_("Audits"), hash_for_system_audits_path(:system_id => @system), :title => _("System audit entries") , :class => 'btn'),
      (link_to_if_authorized(_("Facts"), hash_for_system_facts_path(:system_id => system), :title => _("Browse system facts") , :class => 'btn') if system.fact_values.any?),
      (link_to_if_authorized(_("Reports"), hash_for_system_reports_path(:system_id => system), :title => _("Browse system reports") , :class => 'btn') if system.reports.any?),
      (link_to(_("YAML"), externalNodes_system_path(:name => system), :title => _("Puppet external nodes YAML dump") , :class => 'btn') if SmartProxy.puppet_proxies.any?)
    ].compact
  end
end
