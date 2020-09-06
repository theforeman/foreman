class InitSchema < ActiveRecord::Migration[6.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    create_table "architectures", id: :serial do |t|
      t.string "name", limit: 255, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "architectures_operatingsystems", id: false do |t|
      t.integer "architecture_id", null: false
      t.integer "operatingsystem_id", null: false
    end
    create_table "audits", id: :serial do |t|
      t.integer "auditable_id"
      t.string "auditable_type", limit: 255
      t.integer "user_id"
      t.string "user_type", limit: 255
      t.string "username", limit: 255
      t.string "action", limit: 255
      t.text "audited_changes"
      t.integer "version", default: 0
      t.string "comment", limit: 255
      t.integer "associated_id"
      t.string "associated_type", limit: 255
      t.string "request_uuid", limit: 255
      t.datetime "created_at"
      t.string "remote_address", limit: 255
      t.text "auditable_name"
      t.string "associated_name", limit: 255
      t.index ["associated_type", "associated_id"], name: "index_audits_on_associated_type_and_associated_id"
      t.index ["auditable_type", "auditable_id", "version"], name: "index_audits_on_auditable_type_and_auditable_id_and_version"
      t.index ["created_at"], name: "index_audits_on_created_at"
      t.index ["request_uuid"], name: "index_audits_on_request_uuid"
      t.index ["user_type", "user_id"], name: "index_audits_on_user_type_and_user_id"
    end
    create_table "auth_sources", id: :serial do |t|
      t.string "type", limit: 255, default: "", null: false
      t.string "name", limit: 255, default: "", null: false
      t.string "host", limit: 255
      t.integer "port"
      t.string "account", limit: 255
      t.string "account_password", limit: 255
      t.string "base_dn", limit: 255
      t.string "attr_login", limit: 255
      t.string "attr_firstname", limit: 255
      t.string "attr_lastname", limit: 255
      t.string "attr_mail", limit: 255
      t.boolean "onthefly_register", default: false, null: false
      t.boolean "tls", default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "ldap_filter"
      t.string "attr_photo", limit: 255
      t.string "server_type", limit: 255, default: "posix"
      t.string "groups_base", limit: 255
      t.boolean "usergroup_sync", default: true, null: false
      t.boolean "use_netgroups", default: false
    end
    create_table "bookmarks", id: :serial do |t|
      t.string "name", limit: 255
      t.text "query"
      t.string "controller", limit: 255
      t.boolean "public", default: false, null: false
      t.integer "owner_id"
      t.string "owner_type", limit: 255
      t.index ["controller"], name: "index_bookmarks_on_controller"
      t.index ["name"], name: "index_bookmarks_on_name"
      t.index ["owner_type", "owner_id"], name: "index_bookmarks_on_owner_type_and_owner_id"
    end
    create_table "cached_user_roles", id: :serial do |t|
      t.integer "user_id", null: false
      t.integer "role_id", null: false
      t.integer "user_role_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["role_id"], name: "index_cached_user_roles_on_role_id"
      t.index ["user_id"], name: "index_cached_user_roles_on_user_id"
      t.index ["user_role_id"], name: "index_cached_user_roles_on_user_role_id"
    end
    create_table "cached_usergroup_members", id: :serial do |t|
      t.integer "user_id"
      t.integer "usergroup_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["user_id"], name: "index_cached_usergroup_members_on_user_id"
      t.index ["usergroup_id"], name: "index_cached_usergroup_members_on_usergroup_id"
    end
    create_table "compute_attributes", id: :serial do |t|
      t.integer "compute_profile_id"
      t.integer "compute_resource_id"
      t.string "name", limit: 255
      t.text "vm_attrs"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["compute_profile_id"], name: "index_compute_attributes_on_compute_profile_id"
      t.index ["compute_resource_id"], name: "index_compute_attributes_on_compute_resource_id"
    end
    create_table "compute_profiles", id: :serial do |t|
      t.string "name", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "compute_resources", id: :serial do |t|
      t.string "name", limit: 255
      t.text "description"
      t.string "url", limit: 255
      t.string "user", limit: 255
      t.text "password"
      t.string "uuid", limit: 255
      t.string "type", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "attrs"
      t.boolean "caching_enabled", default: true
      t.string "domain"
      t.integer "http_proxy_id"
    end
    create_table "config_group_classes", id: :serial do |t|
      t.integer "puppetclass_id"
      t.integer "config_group_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "config_groups", id: :serial do |t|
      t.string "name", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "domains", id: :serial do |t|
      t.string "name", limit: 255, default: "", null: false
      t.string "fullname", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "dns_id"
    end
    create_table "environment_classes", id: :serial do |t|
      t.integer "puppetclass_id", null: false
      t.integer "environment_id", null: false
      t.integer "puppetclass_lookup_key_id"
      t.index ["environment_id", "puppetclass_id"], name: "index_environment_classes_on_environment_id_and_puppetclass_id"
      t.index ["puppetclass_id"], name: "index_environment_classes_on_puppetclass_id"
      t.index ["puppetclass_lookup_key_id", "puppetclass_id"], name: "index_env_classes_on_lookup_key_and_class"
    end
    create_table "environments", id: :serial do |t|
      t.string "name", limit: 255, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "external_usergroups", id: :serial do |t|
      t.string "name", limit: 255, null: false
      t.integer "auth_source_id", null: false
      t.integer "usergroup_id", null: false
      t.index ["usergroup_id"], name: "index_external_usergroups_on_usergroup_id"
    end
    create_table "fact_names", id: :serial do |t|
      t.string "name", limit: 255, null: false
      t.datetime "updated_at"
      t.datetime "created_at"
      t.boolean "compose", default: false, null: false
      t.string "short_name", limit: 255
      t.string "type", limit: 255, default: "FactName"
      t.string "ancestry", limit: 255
      t.index ["ancestry", "name"], name: "index_fact_names_on_ancestry_and_name"
      t.index ["name", "type"], name: "index_fact_names_on_name_and_type", unique: true
    end
    create_table "fact_values" do |t|
      t.text "value"
      t.integer "fact_name_id", null: false
      t.integer "host_id", null: false
      t.datetime "updated_at"
      t.datetime "created_at"
      t.index ["fact_name_id", "host_id"], name: "index_fact_values_on_fact_name_id_and_host_id", unique: true
      t.index ["host_id"], name: "index_fact_values_on_host_id"
    end
    create_table "features", id: :serial do |t|
      t.string "name", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "filterings", id: :serial do |t|
      t.integer "filter_id"
      t.integer "permission_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["filter_id"], name: "index_filterings_on_filter_id"
      t.index ["permission_id"], name: "index_filterings_on_permission_id"
    end
    create_table "filters", id: :serial do |t|
      t.text "search"
      t.integer "role_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "taxonomy_search"
      t.boolean "override", default: false, null: false
    end
    create_table "host_classes", id: :serial do |t|
      t.integer "puppetclass_id", null: false
      t.integer "host_id", null: false
    end
    create_table "host_config_groups", id: :serial do |t|
      t.integer "config_group_id"
      t.integer "host_id"
      t.string "host_type", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "host_status", id: :serial do |t|
      t.string "type", limit: 255
      t.bigint "status", default: 0, null: false
      t.integer "host_id", null: false
      t.datetime "reported_at", null: false
      t.index ["host_id"], name: "index_host_status_on_host_id"
      t.index ["type", "host_id"], name: "index_host_status_on_type_and_host_id", unique: true
    end
    create_table "hostgroup_classes", id: :serial do |t|
      t.integer "hostgroup_id", null: false
      t.integer "puppetclass_id", null: false
      t.index ["hostgroup_id"], name: "index_hostgroup_classes_on_hostgroup_id"
      t.index ["puppetclass_id"], name: "index_hostgroup_classes_on_puppetclass_id"
    end
    create_table "hostgroups", id: :serial do |t|
      t.string "name", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "environment_id"
      t.integer "operatingsystem_id"
      t.integer "architecture_id"
      t.integer "medium_id"
      t.integer "ptable_id"
      t.string "root_pass", limit: 255
      t.integer "puppet_ca_proxy_id"
      t.boolean "use_image"
      t.string "image_file", limit: 128
      t.string "ancestry", limit: 255
      t.text "vm_defaults"
      t.integer "subnet_id"
      t.integer "domain_id"
      t.integer "puppet_proxy_id"
      t.string "title", limit: 255
      t.integer "realm_id"
      t.integer "compute_profile_id"
      t.string "grub_pass", limit: 255, default: ""
      t.string "lookup_value_matcher", limit: 255
      t.integer "subnet6_id"
      t.string "pxe_loader", limit: 255
      t.text "description"
      t.integer "compute_resource_id"
      t.index ["ancestry"], name: "index_hostgroups_on_ancestry"
      t.index ["compute_profile_id"], name: "index_hostgroups_on_compute_profile_id"
    end
    create_table "hosts", id: :serial do |t|
      t.string "name", limit: 255, null: false
      t.datetime "last_compile"
      t.datetime "last_report"
      t.datetime "updated_at"
      t.datetime "created_at"
      t.string "root_pass", limit: 255
      t.integer "architecture_id"
      t.integer "operatingsystem_id"
      t.integer "environment_id"
      t.integer "ptable_id"
      t.integer "medium_id"
      t.boolean "build", default: false
      t.text "comment"
      t.text "disk"
      t.datetime "installed_at"
      t.integer "model_id"
      t.integer "hostgroup_id"
      t.integer "owner_id"
      t.string "owner_type", limit: 255
      t.boolean "enabled", default: true
      t.integer "puppet_ca_proxy_id"
      t.boolean "managed", default: false, null: false
      t.boolean "use_image"
      t.string "image_file", limit: 128
      t.string "uuid", limit: 255
      t.integer "compute_resource_id"
      t.integer "puppet_proxy_id"
      t.string "certname", limit: 255
      t.integer "image_id"
      t.integer "organization_id"
      t.integer "location_id"
      t.string "type", limit: 255
      t.string "otp", limit: 255
      t.integer "realm_id"
      t.integer "compute_profile_id"
      t.string "provision_method", limit: 255
      t.string "grub_pass", limit: 255, default: ""
      t.integer "global_status", default: 0, null: false
      t.string "lookup_value_matcher", limit: 255
      t.string "pxe_loader", limit: 255
      t.datetime "initiated_at"
      t.text "build_errors"
      t.index ["architecture_id"], name: "host_arch_id_ix"
      t.index ["certname"], name: "index_hosts_on_certname"
      t.index ["compute_profile_id"], name: "index_hosts_on_compute_profile_id"
      t.index ["environment_id"], name: "host_env_id_ix"
      t.index ["hostgroup_id"], name: "host_group_id_ix"
      t.index ["installed_at"], name: "index_hosts_on_installed_at"
      t.index ["last_report"], name: "index_hosts_on_last_report"
      t.index ["medium_id"], name: "host_medium_id_ix"
      t.index ["name"], name: "index_hosts_on_name"
      t.index ["operatingsystem_id"], name: "host_os_id_ix"
      t.index ["type", "location_id"], name: "index_hosts_on_type_and_location_id"
      t.index ["type", "organization_id", "location_id"], name: "index_hosts_on_type_and_organization_id_and_location_id"
    end
    create_table "http_proxies", id: :serial do |t|
      t.string "name", null: false
      t.string "url", null: false
      t.string "username"
      t.string "password"
    end
    create_table "images", id: :serial do |t|
      t.integer "operatingsystem_id"
      t.integer "compute_resource_id"
      t.integer "architecture_id"
      t.string "uuid", limit: 255
      t.string "username", limit: 255
      t.string "name", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "iam_role", limit: 255
      t.boolean "user_data", default: false
      t.string "password", limit: 255
      t.index ["name", "compute_resource_id", "operatingsystem_id"], name: "image_name_index", unique: true
      t.index ["uuid", "compute_resource_id"], name: "image_uuid_index", unique: true
    end
    create_table "jwt_secrets" do |t|
      t.string "token", null: false
      t.integer "user_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["token"], name: "index_jwt_secrets_on_token", unique: true
      t.index ["user_id"], name: "index_jwt_secrets_on_user_id"
    end
    create_table "key_pairs", id: :serial do |t|
      t.text "secret"
      t.integer "compute_resource_id"
      t.string "name", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "public"
    end
    create_table "locations_organizations", id: false do |t|
      t.integer "location_id"
      t.integer "organization_id"
    end
    create_table "logs" do |t|
      t.integer "source_id"
      t.integer "message_id"
      t.integer "report_id"
      t.integer "level_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["level_id"], name: "index_logs_on_level_id"
      t.index ["message_id"], name: "index_logs_on_message_id"
      t.index ["report_id"], name: "index_logs_on_report_id"
      t.index ["source_id"], name: "index_logs_on_source_id"
    end
    create_table "lookup_keys", id: :serial do |t|
      t.string "key", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "puppetclass_id"
      t.text "default_value"
      t.text "path"
      t.text "description"
      t.string "validator_type", limit: 255
      t.string "validator_rule", limit: 255
      t.string "key_type", limit: 255
      t.boolean "override", default: false
      t.boolean "required", default: false
      t.boolean "merge_overrides", default: false, null: false
      t.boolean "avoid_duplicates", default: false, null: false
      t.boolean "omit"
      t.string "type", limit: 255
      t.boolean "merge_default", default: false, null: false
      t.boolean "hidden_value", default: false
      t.index ["key"], name: "index_lookup_keys_on_key"
      t.index ["puppetclass_id"], name: "index_lookup_keys_on_puppetclass_id"
      t.index ["type"], name: "index_lookup_keys_on_type"
    end
    create_table "lookup_values", id: :serial do |t|
      t.string "match", limit: 255
      t.text "value"
      t.integer "lookup_key_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean "omit", default: false
      t.index ["lookup_key_id"], name: "index_lookup_values_on_lookup_key_id"
      t.index ["match"], name: "index_lookup_values_on_match"
    end
    create_table "mail_notifications", id: :serial do |t|
      t.string "name", limit: 255
      t.text "description"
      t.string "mailer", limit: 255
      t.string "method", limit: 255
      t.boolean "subscriptable", default: true
      t.string "default_interval", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "subscription_type", limit: 255
      t.boolean "queryable", default: false
      t.string "type", limit: 255
    end
    create_table "media", id: :serial do |t|
      t.string "name", limit: 255, default: "", null: false
      t.string "path", limit: 255, default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "media_path", limit: 255
      t.string "config_path", limit: 255
      t.string "image_path", limit: 255
      t.string "os_family", limit: 255
    end
    create_table "media_operatingsystems", id: false do |t|
      t.integer "medium_id", null: false
      t.integer "operatingsystem_id", null: false
    end
    create_table "messages", id: :serial do |t|
      t.text "value"
      t.string "digest", limit: 40
      t.index ["digest"], name: "index_messages_on_digest"
    end
    create_table "models", id: :serial do |t|
      t.string "name", limit: 255, null: false
      t.text "info"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "vendor_class", limit: 255
      t.string "hardware_model", limit: 255
    end
    create_table "nics", id: :serial do |t|
      t.string "mac", limit: 255
      t.string "ip", limit: 15
      t.string "type", limit: 255
      t.string "name", limit: 255
      t.integer "host_id"
      t.integer "subnet_id"
      t.integer "domain_id"
      t.text "attrs"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "provider", limit: 255
      t.string "username", limit: 255
      t.string "password", limit: 255
      t.boolean "virtual", default: false, null: false
      t.boolean "link", default: true, null: false
      t.string "identifier", limit: 255
      t.string "tag", limit: 255, default: "", null: false
      t.string "attached_to", limit: 255, default: "", null: false
      t.boolean "managed", default: true
      t.string "mode", limit: 255, default: "balance-rr", null: false
      t.string "attached_devices", limit: 255, default: "", null: false
      t.string "bond_options", limit: 255, default: "", null: false
      t.boolean "primary", default: false
      t.boolean "provision", default: false
      t.text "compute_attributes"
      t.string "ip6", limit: 45
      t.integer "subnet6_id"
      t.index ["host_id"], name: "index_by_host"
      t.index ["ip"], name: "index_nics_on_ip"
      t.index ["ip6"], name: "index_nics_on_ip6"
      t.index ["type", "id"], name: "index_by_type_and_id"
    end
    create_table "notification_blueprints", id: :serial do |t|
      t.string "group"
      t.string "level"
      t.string "message"
      t.text "name"
      t.integer "expires_in"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.text "actions"
      t.index ["group"], name: "index_notification_blueprints_on_group"
    end
    create_table "notification_recipients", id: :serial do |t|
      t.integer "notification_id"
      t.integer "user_id"
      t.boolean "seen", default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["notification_id"], name: "index_notification_recipients_on_notification_id"
      t.index ["seen"], name: "index_notification_recipients_on_seen"
      t.index ["user_id", "notification_id"], name: "index_notification_recipients_on_user_id_and_notification_id"
    end
    create_table "notifications", id: :serial do |t|
      t.integer "notification_blueprint_id", null: false
      t.integer "user_id"
      t.string "audience"
      t.datetime "expired_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "subject_type"
      t.integer "subject_id"
      t.string "message"
      t.text "actions"
      t.index ["expired_at"], name: "index_notifications_on_expired_at"
      t.index ["notification_blueprint_id"], name: "index_notifications_on_notification_blueprint_id"
      t.index ["subject_type", "subject_id"], name: "index_notifications_on_subject_type_and_subject_id"
      t.index ["user_id"], name: "index_notifications_on_user_id"
    end
    create_table "operatingsystems", id: :serial do |t|
      t.string "major", limit: 5, default: "", null: false
      t.string "name", limit: 255, null: false
      t.string "minor", limit: 16, default: "", null: false
      t.string "nameindicator", limit: 3
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "release_name", limit: 255
      t.string "type", limit: 255
      t.string "description", limit: 255
      t.string "password_hash", limit: 255, default: "SHA256"
      t.string "title", limit: 255
      t.index ["name", "major", "minor"], name: "index_operatingsystems_on_name_and_major_and_minor", unique: true
      t.index ["title"], name: "index_operatingsystems_on_title", unique: true
      t.index ["type"], name: "index_operatingsystems_on_type"
    end
    create_table "operatingsystems_provisioning_templates", id: false do |t|
      t.integer "provisioning_template_id", null: false
      t.integer "operatingsystem_id", null: false
    end
    create_table "operatingsystems_ptables", id: false do |t|
      t.integer "ptable_id", null: false
      t.integer "operatingsystem_id", null: false
    end
    create_table "operatingsystems_puppetclasses", id: false do |t|
      t.integer "puppetclass_id", null: false
      t.integer "operatingsystem_id", null: false
    end
    create_table "os_default_templates", id: :serial do |t|
      t.integer "provisioning_template_id"
      t.integer "template_kind_id"
      t.integer "operatingsystem_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "parameters", id: :serial do |t|
      t.string "name", limit: 255
      t.text "value"
      t.integer "reference_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "type", limit: 255
      t.integer "priority"
      t.boolean "hidden_value", default: false
      t.string "key_type", limit: 255
      t.index ["type", "reference_id", "name"], name: "index_parameters_on_type_and_reference_id_and_name", unique: true
    end
    create_table "permissions", id: :serial do |t|
      t.string "name", limit: 255, null: false
      t.string "resource_type", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["name", "resource_type"], name: "index_permissions_on_name_and_resource_type"
    end
    create_table "personal_access_tokens", id: :serial do |t|
      t.string "token", null: false
      t.string "name", null: false
      t.datetime "expires_at"
      t.datetime "last_used_at"
      t.boolean "revoked", default: false
      t.integer "user_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["token"], name: "index_personal_access_tokens_on_token", unique: true
      t.index ["user_id"], name: "index_personal_access_tokens_on_user_id"
    end
    create_table "puppetclasses", id: :serial do |t|
      t.string "name", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["name"], name: "index_puppetclasses_on_name", unique: true
    end
    create_table "realms", id: :serial do |t|
      t.string "name", limit: 255, default: "", null: false
      t.string "realm_type", limit: 255
      t.integer "realm_proxy_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["name"], name: "index_realms_on_name", unique: true
    end
    create_table "reports" do |t|
      t.integer "host_id", null: false
      t.datetime "reported_at", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.bigint "status"
      t.text "metrics"
      t.string "type", limit: 255, default: "ConfigReport", null: false
      t.string "origin"
      t.index ["host_id", "type", "id"], name: "index_reports_on_host_id_and_type_and_id"
      t.index ["reported_at", "host_id", "type"], name: "index_reports_on_reported_at_and_host_id_and_type"
      t.index ["status"], name: "index_reports_on_status"
      t.index ["type", "host_id"], name: "index_reports_on_type_and_host_id"
    end
    create_table "roles", id: :serial do |t|
      t.string "name", limit: 255
      t.integer "builtin", default: 0
      t.text "description"
      t.string "origin"
      t.integer "cloned_from_id"
      t.index ["name"], name: "index_roles_on_name", unique: true
    end
    create_table "sessions", id: :serial do |t|
      t.string "session_id", limit: 255, null: false
      t.text "data"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["session_id"], name: "index_sessions_on_session_id"
      t.index ["updated_at"], name: "index_sessions_on_updated_at"
    end
    create_table "settings", id: :serial do |t|
      t.string "name", limit: 255
      t.text "value"
      t.text "description"
      t.string "category", limit: 255
      t.string "settings_type", limit: 255
      t.text "default", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "full_name", limit: 255
      t.boolean "encrypted", default: false, null: false
      t.index ["category"], name: "index_settings_on_category"
      t.index ["name"], name: "index_settings_on_name", unique: true
    end
    create_table "smart_proxies", id: :serial do |t|
      t.string "name", limit: 255
      t.string "url", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "expired_logs", limit: 255, default: "0"
    end
    create_table "smart_proxy_features" do |t|
      t.integer "smart_proxy_id"
      t.integer "feature_id"
      t.text "capabilities"
      t.text "settings"
    end
    create_table "sources", id: :serial do |t|
      t.text "value"
      t.string "digest", limit: 40
      t.index ["digest"], name: "index_sources_on_digest"
    end
    create_table "ssh_keys", id: :serial do |t|
      t.string "name", limit: 255
      t.text "key"
      t.string "fingerprint"
      t.integer "user_id"
      t.integer "length"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["user_id"], name: "index_ssh_keys_on_user_id"
    end
    create_table "subnet_domains", id: :serial do |t|
      t.integer "domain_id", null: false
      t.integer "subnet_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["subnet_id", "domain_id"], name: "index_subnet_domains_on_subnet_id_and_domain_id", unique: true
    end
    create_table "subnets", id: :serial do |t|
      t.string "network", limit: 45
      t.string "mask", limit: 45
      t.integer "priority"
      t.text "name"
      t.integer "vlanid"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "dhcp_id"
      t.integer "tftp_id"
      t.string "gateway", limit: 45
      t.string "dns_primary", limit: 45
      t.string "dns_secondary", limit: 45
      t.string "from", limit: 45
      t.string "to", limit: 45
      t.integer "dns_id"
      t.string "boot_mode", default: "DHCP", null: false
      t.string "ipam", limit: 255, default: "None", null: false
      t.string "type", default: "Subnet::Ipv4", null: false
      t.text "description"
      t.bigint "mtu", default: 1500, null: false
      t.integer "template_id"
      t.integer "httpboot_id"
      t.integer "nic_delay"
      t.index ["httpboot_id"], name: "index_subnets_on_httpboot_id"
      t.index ["name"], name: "index_subnets_on_name", unique: true
      t.index ["type"], name: "index_subnets_on_type"
    end
    create_table "table_preferences" do |t|
      t.string "name", limit: 255, null: false
      t.text "columns"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "user_id", null: false
      t.index ["user_id", "name"], name: "index_table_preferences_on_user_id_and_name", unique: true
    end
    create_table "taxable_taxonomies", id: :serial do |t|
      t.integer "taxonomy_id"
      t.integer "taxable_id"
      t.string "taxable_type", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["taxable_type", "taxable_id", "taxonomy_id"], name: "taxable_index", unique: true
      t.index ["taxonomy_id"], name: "index_taxable_taxonomies_on_taxonomy_id"
    end
    create_table "taxonomies", id: :serial do |t|
      t.string "name", limit: 255
      t.string "type", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "ignore_types"
      t.string "ancestry", limit: 255
      t.string "title", limit: 255
      t.text "description"
      t.index ["ancestry"], name: "index_taxonomies_on_ancestry"
    end
    create_table "template_combinations", id: :serial do |t|
      t.integer "provisioning_template_id"
      t.integer "hostgroup_id"
      t.integer "environment_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "template_inputs", id: :serial do |t|
      t.string "name", limit: 255, null: false
      t.boolean "required", default: false, null: false
      t.string "input_type", limit: 255, null: false
      t.string "fact_name", limit: 255
      t.string "variable_name", limit: 255
      t.string "puppet_class_name", limit: 255
      t.string "puppet_parameter_name", limit: 255
      t.text "description"
      t.integer "template_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "options"
      t.boolean "advanced", default: false, null: false
    end
    create_table "template_kinds", id: :serial do |t|
      t.string "name", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "description"
    end
    create_table "templates", id: :serial do |t|
      t.string "name", limit: 255
      t.text "template"
      t.boolean "snippet", default: false, null: false
      t.integer "template_kind_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean "locked", default: false
      t.boolean "default", default: false
      t.string "vendor", limit: 255
      t.string "type"
      t.string "os_family", limit: 255
    end
    create_table "tokens", id: :serial do |t|
      t.text "value"
      t.datetime "expires"
      t.integer "host_id"
      t.string "type", default: "Token::Build", null: false
      t.index ["host_id"], name: "index_tokens_on_host_id"
      t.index ["value"], name: "index_tokens_on_value"
    end
    create_table "upgrade_tasks" do |t|
      t.string "name", null: false
      t.string "task_name", null: false
      t.boolean "long_running", default: false, null: false
      t.boolean "always_run", default: false, null: false
      t.boolean "skip_failure", default: false, null: false
      t.datetime "last_run_time"
      t.integer "ordering", default: 100, null: false
      t.string "subject", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["name"], name: "index_upgrade_tasks_on_name", unique: true
    end
    create_table "user_mail_notifications", id: :serial do |t|
      t.integer "user_id"
      t.integer "mail_notification_id"
      t.datetime "last_sent"
      t.string "interval", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "mail_query", limit: 255
    end
    create_table "user_roles", id: :serial do |t|
      t.integer "owner_id", null: false
      t.integer "role_id"
      t.string "owner_type", limit: 255, default: "User", null: false
      t.index ["owner_id"], name: "index_user_roles_on_owner_id"
      t.index ["owner_type", "owner_id"], name: "index_user_roles_on_owner_type_and_owner_id"
    end
    create_table "usergroup_members", id: :serial do |t|
      t.string "member_type"
      t.integer "member_id"
      t.integer "usergroup_id"
    end
    create_table "usergroups", id: :serial do |t|
      t.string "name", limit: 255, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean "admin", default: false, null: false
    end
    create_table "users", id: :serial do |t|
      t.string "login", limit: 255
      t.string "firstname", limit: 255
      t.string "lastname", limit: 255
      t.string "mail", limit: 255
      t.boolean "admin", default: false, null: false
      t.datetime "last_login_on"
      t.integer "auth_source_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "password_hash", limit: 128
      t.string "password_salt", limit: 128
      t.string "locale", limit: 5
      t.string "avatar_hash", limit: 128
      t.integer "default_organization_id"
      t.integer "default_location_id"
      t.string "lower_login", limit: 255
      t.boolean "mail_enabled", default: true
      t.string "timezone", limit: 255
      t.text "description"
      t.index ["lower_login"], name: "index_users_on_lower_login", unique: true
    end
    create_table "widgets", id: :serial do |t|
      t.integer "user_id"
      t.string "template", limit: 255, null: false
      t.string "name", limit: 255, null: false
      t.text "data"
      t.integer "sizex", default: 4
      t.integer "sizey", default: 1
      t.integer "col", default: 1
      t.integer "row", default: 1
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["user_id"], name: "index_widgets_on_user_id"
    end
    add_foreign_key "architectures_operatingsystems", "architectures", name: "architectures_operatingsystems_architecture_id_fk"
    add_foreign_key "architectures_operatingsystems", "operatingsystems", name: "architectures_operatingsystems_operatingsystem_id_fk"
    add_foreign_key "compute_attributes", "compute_profiles", name: "compute_attributes_compute_profile_id_fk"
    add_foreign_key "compute_attributes", "compute_resources", name: "compute_attributes_compute_resource_id_fk"
    add_foreign_key "domains", "smart_proxies", column: "dns_id", name: "domains_dns_id_fk"
    add_foreign_key "environment_classes", "environments", name: "environment_classes_environment_id_fk"
    add_foreign_key "environment_classes", "lookup_keys", column: "puppetclass_lookup_key_id", name: "environment_classes_lookup_key_id_fk"
    add_foreign_key "environment_classes", "puppetclasses", name: "environment_classes_puppetclass_id_fk"
    add_foreign_key "external_usergroups", "auth_sources", name: "external_usergroups_auth_source_id_fk"
    add_foreign_key "external_usergroups", "usergroups", name: "external_usergroups_usergroup_id_fk"
    add_foreign_key "fact_values", "fact_names", name: "fact_values_fact_name_id_fk"
    add_foreign_key "fact_values", "hosts", name: "fact_values_host_id_fk"
    add_foreign_key "filterings", "filters", name: "filterings_filters_id_fk"
    add_foreign_key "filterings", "permissions", name: "filterings_permissions_id_fk"
    add_foreign_key "filters", "roles", name: "filters_roles_id_fk"
    add_foreign_key "host_classes", "hosts", name: "host_classes_host_id_fk"
    add_foreign_key "host_classes", "puppetclasses", name: "host_classes_puppetclass_id_fk"
    add_foreign_key "host_status", "hosts", name: "host_status_hosts_host_id_fk"
    add_foreign_key "hostgroup_classes", "hostgroups", name: "hostgroup_classes_hostgroup_id_fk"
    add_foreign_key "hostgroup_classes", "puppetclasses", name: "hostgroup_classes_puppetclass_id_fk"
    add_foreign_key "hostgroups", "architectures", name: "hostgroups_architecture_id_fk"
    add_foreign_key "hostgroups", "compute_profiles", name: "hostgroups_compute_profile_id_fk"
    add_foreign_key "hostgroups", "compute_resources"
    add_foreign_key "hostgroups", "domains", name: "hostgroups_domain_id_fk"
    add_foreign_key "hostgroups", "environments", name: "hostgroups_environment_id_fk"
    add_foreign_key "hostgroups", "media", name: "hostgroups_medium_id_fk"
    add_foreign_key "hostgroups", "operatingsystems", name: "hostgroups_operatingsystem_id_fk"
    add_foreign_key "hostgroups", "realms", name: "hostgroups_realms_id_fk"
    add_foreign_key "hostgroups", "smart_proxies", column: "puppet_ca_proxy_id", name: "hostgroups_puppet_ca_proxy_id_fk"
    add_foreign_key "hostgroups", "smart_proxies", column: "puppet_proxy_id", name: "hostgroups_puppet_proxy_id_fk"
    add_foreign_key "hostgroups", "subnets", name: "hostgroups_subnet_id_fk"
    add_foreign_key "hostgroups", "templates", column: "ptable_id", name: "hostgroups_ptable_id_fk"
    add_foreign_key "hosts", "architectures", name: "hosts_architecture_id_fk"
    add_foreign_key "hosts", "compute_profiles", name: "hosts_compute_profile_id_fk"
    add_foreign_key "hosts", "compute_resources", name: "hosts_compute_resource_id_fk"
    add_foreign_key "hosts", "environments", name: "hosts_environment_id_fk"
    add_foreign_key "hosts", "hostgroups", name: "hosts_hostgroup_id_fk"
    add_foreign_key "hosts", "images", name: "hosts_image_id_fk"
    add_foreign_key "hosts", "media", name: "hosts_medium_id_fk"
    add_foreign_key "hosts", "models", name: "hosts_model_id_fk"
    add_foreign_key "hosts", "operatingsystems", name: "hosts_operatingsystem_id_fk"
    add_foreign_key "hosts", "realms", name: "hosts_realms_id_fk"
    add_foreign_key "hosts", "smart_proxies", column: "puppet_ca_proxy_id", name: "hosts_puppet_ca_proxy_id_fk"
    add_foreign_key "hosts", "smart_proxies", column: "puppet_proxy_id", name: "hosts_puppet_proxy_id_fk"
    add_foreign_key "hosts", "taxonomies", column: "location_id", name: "hosts_location_id_fk"
    add_foreign_key "hosts", "taxonomies", column: "organization_id", name: "hosts_organization_id_fk"
    add_foreign_key "hosts", "templates", column: "ptable_id", name: "hosts_ptable_id_fk"
    add_foreign_key "images", "architectures", name: "images_architecture_id_fk"
    add_foreign_key "images", "compute_resources", name: "images_compute_resource_id_fk"
    add_foreign_key "images", "operatingsystems", name: "images_operatingsystem_id_fk"
    add_foreign_key "jwt_secrets", "users"
    add_foreign_key "key_pairs", "compute_resources", name: "key_pairs_compute_resource_id_fk"
    add_foreign_key "lookup_keys", "puppetclasses", name: "lookup_keys_puppetclass_id_fk"
    add_foreign_key "lookup_values", "lookup_keys", name: "lookup_values_lookup_key_id_fk"
    add_foreign_key "media_operatingsystems", "media", name: "media_operatingsystems_medium_id_fk"
    add_foreign_key "media_operatingsystems", "operatingsystems", name: "media_operatingsystems_operatingsystem_id_fk"
    add_foreign_key "nics", "domains", name: "nics_domain_id_fk"
    add_foreign_key "nics", "hosts", name: "nics_host_id_fk"
    add_foreign_key "nics", "subnets", name: "nics_subnet_id_fk"
    add_foreign_key "notification_recipients", "notifications"
    add_foreign_key "notification_recipients", "users"
    add_foreign_key "notifications", "notification_blueprints"
    add_foreign_key "notifications", "users"
    add_foreign_key "operatingsystems_provisioning_templates", "operatingsystems", name: "config_templates_operatingsystems_operatingsystem_id_fk"
    add_foreign_key "operatingsystems_provisioning_templates", "templates", column: "provisioning_template_id", name: "os_provisioning_template_id_fk"
    add_foreign_key "operatingsystems_ptables", "operatingsystems", name: "operatingsystems_ptables_operatingsystem_id_fk"
    add_foreign_key "operatingsystems_ptables", "templates", column: "ptable_id", name: "operatingsystems_ptables_ptable_id_fk"
    add_foreign_key "operatingsystems_puppetclasses", "operatingsystems", name: "operatingsystems_puppetclasses_operatingsystem_id_fk"
    add_foreign_key "operatingsystems_puppetclasses", "puppetclasses", name: "operatingsystems_puppetclasses_puppetclass_id_fk"
    add_foreign_key "os_default_templates", "operatingsystems", name: "os_default_templates_operatingsystem_id_fk"
    add_foreign_key "os_default_templates", "template_kinds", name: "os_default_templates_template_kind_id_fk"
    add_foreign_key "os_default_templates", "templates", column: "provisioning_template_id", name: "os_default_templates_provisioning_template_id_fk"
    add_foreign_key "personal_access_tokens", "users"
    add_foreign_key "realms", "smart_proxies", column: "realm_proxy_id", name: "realms_realm_proxy_id_fk"
    add_foreign_key "reports", "hosts", name: "reports_host_id_fk"
    add_foreign_key "smart_proxy_features", "features", name: "features_smart_proxies_feature_id_fk"
    add_foreign_key "smart_proxy_features", "smart_proxies", name: "features_smart_proxies_smart_proxy_id_fk"
    add_foreign_key "subnet_domains", "domains", name: "subnet_domains_domain_id_fk"
    add_foreign_key "subnet_domains", "subnets", name: "subnet_domains_subnet_id_fk"
    add_foreign_key "subnets", "smart_proxies", column: "dhcp_id", name: "subnets_dhcp_id_fk"
    add_foreign_key "subnets", "smart_proxies", column: "dns_id", name: "subnets_dns_id_fk"
    add_foreign_key "subnets", "smart_proxies", column: "tftp_id", name: "subnets_tftp_id_fk"
    add_foreign_key "table_preferences", "users", name: "table_preferences_user_id_fk"
    add_foreign_key "taxable_taxonomies", "taxonomies", name: "taxable_taxonomies_taxonomy_id_fk"
    add_foreign_key "template_combinations", "environments", name: "template_combinations_environment_id_fk"
    add_foreign_key "template_combinations", "hostgroups", name: "template_combinations_hostgroup_id_fk"
    add_foreign_key "template_combinations", "templates", column: "provisioning_template_id", name: "template_combinations_provisioning_template_id_fk"
    add_foreign_key "template_inputs", "templates", name: "templates_template_id_fk"
    add_foreign_key "templates", "template_kinds", name: "config_templates_template_kind_id_fk"
    add_foreign_key "tokens", "hosts", name: "tokens_host_id_fk"
    add_foreign_key "user_mail_notifications", "mail_notifications", name: "user_mail_notifications_mail_notification_id_fk"
    add_foreign_key "user_mail_notifications", "users", name: "user_mail_notifications_user_id_fk"
    add_foreign_key "user_roles", "roles", name: "user_roles_role_id_fk"
    add_foreign_key "usergroup_members", "usergroups", name: "usergroup_members_usergroup_id_fk"
    add_foreign_key "users", "auth_sources", name: "users_auth_source_id_fk"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
