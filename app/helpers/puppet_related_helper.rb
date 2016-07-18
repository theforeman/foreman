module PuppetRelatedHelper
  def host_puppet_environment_field(form, select_options = {}, html_options = {})
    select_options = {
      :include_blank => true,
      :disable_button => _(HostsAndHostgroupsHelper::INHERIT_TEXT),
      :disable_button_enabled => inherited_by_default?(:environment_id, @host),
      :user_set => user_set?(:environment_id)}.deep_merge(select_options)

    html_options = {
      :data => {
        :url => hostgroup_or_environment_selected_hosts_path,
        :host => {
          :id => @host.id
        }
      }}.deep_merge(html_options)

    puppet_environment_field(
      form,
      accessible_resource(@host, :environment),
      select_options,
      html_options)
  end

  def hostgroup_puppet_environment_field(form, select_options = {}, html_options = {})
    select_options = {
      :include_blank => blank_or_inherit_f(form, :environment)
    }.deep_merge(select_options)

    html_options = {
      :data => {
        :url => environment_selected_hostgroups_path
      }}.deep_merge(html_options)

    puppet_environment_field(
      form,
      accessible_resource(@hostgroup, :environment),
      select_options,
      html_options)
  end

  def puppet_environment_field(form, environments_choice, select_options = {}, html_options = {})
    html_options = {
      :onchange => "update_puppetclasses(this)",
      :help_inline => :indicator}.deep_merge(html_options)

    select_f(
      form,
      :environment_id,
      environments_choice,
      :id,
      :to_label,
      select_options,
      html_options)
  end

  def interesting_puppetclasses(obj)
    classes = obj.all_puppetclasses
    classes_ids = classes.reorder("").pluck("puppetclasses.id")
    smart_vars = VariableLookupKey.reorder("").where(:puppetclass_id => classes_ids).distinct.pluck(:puppetclass_id)
    class_vars = PuppetclassLookupKey.reorder("").joins(:environment_classes).where(:environment_classes => { :puppetclass_id => classes_ids }).distinct.pluck("environment_classes.puppetclass_id")
    klasses    = (smart_vars + class_vars).uniq

    classes.where(:id => klasses)
  end

  def puppetclasses_tab(puppetclasses_receiver)
    content_tag(:div, :class => "tab-pane", :id => "puppet_klasses") do
      if @environment.present? ||
          @hostgroup.present? && @hostgroup.environment.present?
        render "puppetclasses/class_selection", :obj => puppetclasses_receiver
      else
        alert(:class => "alert-info", :header => _("Notice"),
              :text => _("Please select an environment first"))
      end
    end
  end
end
