class CategorizeConfigManagementSettings < ActiveRecord::Migration[6.0]
  def up
    moved_settings.each do |to_category, setting_names|
      Setting.where(name: setting_names).update_all(category: to_category)
    end
  end

  def down
    # The settings should not move back
  end

  private

  def moved_settings
    {
      'Setting::Cfgmgmt' => %w[
        matchers_inheritance
        Default_parameters_Lookup_Path
        interpolate_erb_in_parameters
        create_new_host_when_facts_are_uploaded
        always_show_configuration_status
        puppet_interval
        puppet_out_of_sync_disabled
      ],
      'Setting::Facts' => %[
        default_location
        default_organization
        update_subnets_from_facts
        update_hostgroup_from_facts
        create_new_host_when_report_is_uploaded
        location_fact
        organization_fact
        ignore_facts_for_operatingsystem
        ignore_facts_for_domain
        excluded_facts
        default_puppet_environment
        enc_environment
        update_environment_from_facts
        ignore_puppet_facts_for_provisioning
      ],
      'Setting::Provisioning' => %[use_uuid_for_certificates],
    }
  end
end
