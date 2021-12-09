# Foreman telemetry metrics registration.
#
# There are three types of telemetry measurements: counter, gauge, histogram. Each measurement has unique name
# represented by a symbol, a description and list of tags which are required and mapped to monitoring frameworks
# which do not support arbitrary tags.
#
# Plugins can add own metrics through add_counter_telemetry, add_gauge_telemetry and add_histogram_telemetry.
#
telemetry = Foreman::Telemetry.instance

# Foreman telemetry global setup.
if SETTINGS[:telemetry] && (Rails.env.production? || Rails.env.development?)
  telemetry.setup(SETTINGS[:telemetry])
end

# Register Rails notifications metrics
telemetry.register_rails

# Register Ruby VM metrics
telemetry.register_ruby

telemetry.add_counter(:http_requests, 'A counter of HTTP requests made', [:controller, :action, :status])
telemetry.add_histogram(:http_request_total_duration, 'Total duration of controller action', [:controller, :action])
telemetry.add_histogram(:http_request_db_duration, 'Time spent in database for a request', [:controller, :action])
telemetry.add_histogram(:http_request_view_duration, 'Time spent in view for a request', [:controller, :action])
telemetry.add_counter(:activerecord_instances, 'Number of instances of ActiveRecord models', [:class])
telemetry.add_counter(:successful_ui_logins, 'Number of successful logins in total')
telemetry.add_counter(:failed_ui_logins, 'Number of failed logins in total')
telemetry.add_counter(:bruteforce_locked_ui_logins, 'Number of blocked logins via bruteforce protection')
telemetry.add_histogram(:login_pwhash_duration, 'Duration of password hash algorithm', [:algorithm])
telemetry.add_histogram(:proxy_api_duration, 'Time spent waiting for Proxy (ms)', [:method])
telemetry.add_counter(:proxy_api_response_code, 'Number of Proxy API responses per HTTP code', [:code])
telemetry.add_histogram(:importer_facts_import_duration, 'Duration of fact import (ms) per importer type', [:type])
telemetry.add_histogram(:importer_facts_populate_duration, 'Duration of fields population (ms) per importer type', [:type])
telemetry.add_counter(:importer_facts_count_input, 'Number of facts before imports starts per importer type', [:type])
telemetry.add_counter(:importer_facts_count_processed, 'Number of facts processed (added, updated, deleted) per importer type', [:type, :action])
telemetry.add_counter(:importer_facts_count_interfaces, 'Number of changed interfaces per importer type', [:type])
telemetry.add_histogram(:ldap_request_duration, 'Total duration of LDAP requests')
telemetry.add_histogram(:report_importer_create, 'Total duration of report import creation', [:type])
telemetry.add_histogram(:report_importer_refresh, 'Total duration of report status refresh', [:type])
telemetry.add_counter(:audit_records_created, 'Number of audit records created in the DB', [:type])
telemetry.add_counter(:audit_records_logged, 'Number of audit records sent into logger', [:type])
telemetry.add_counter(:config_report_metric_count, 'Number of config report status metrics', [:metric])
telemetry.add_counter(:authorizer_cache_records_fetched, 'Number of records fetched by authorizer cache', [:class])

# To decrease amount of metrics, labels must be allowed explicitly
allowed_labels = {
  controller: [
    'api/v2/config_reports_controller',
    'api/v2/hosts_controller',
    'api/v2/puppet_hosts_controller',
    'config_reports_controller',
    'dashboard_controller',
    'fact_values_controller',
    'hostgroups_controller',
    'hosts_controller',
    'notification_recipients_controller',
  ],
  action: [
    'index',
    'show',
    'create',
    'update',
    'destroy',
    'export',
    'generate',
    'facts',
  ],
  class: [
    'Architecture',
    'AuthSource',
    'Bookmark',
    'CommonParameter',
    'ComputeResource',
    'ConfigReport',
    'Domain',
    'DomainParameter',
    'Environment',
    'FactName',
    'FactValue',
    'Filter',
    'Filtering',
    'GroupParameter',
    'Host::Base',
    'Host::Managed',
    'Hostgroup',
    'HostParameter',
    'Image',
    'JobTemplate',
    'Location',
    'LocationParameter',
    'LookupKey',
    'LookupValue',
    'Model',
    'Nic::Base',
    'Nic::BMC',
    'Nic::Bond',
    'Nic::Bridge',
    'Nic::Interface',
    'Nic::Managed',
    'Operatingsystem',
    'Organization',
    'OrganizationParameter',
    'OsParameter',
    'Parameter',
    'ProvisioningTemplate',
    'Ptable',
    'PuppetclassLookupKey',
    'Realm',
    'RemoteExecutionFeature',
    'Report',
    'Role',
    'SmartProxy',
    'Subnet',
    'SubnetParameter',
    'Taxonomy',
    'Template',
    'TemplateInput',
    'TemplateInvocation',
    'TemplateKind',
    'User',
    'Usergroup',
    'Widget',
  ],
}
telemetry.add_allowed_tags!(allowed_labels)
