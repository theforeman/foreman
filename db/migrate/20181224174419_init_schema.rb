class InitSchema < ActiveRecord::Migration[6.0]
  class SchemaMigration < ApplicationRecord
  end

  REMOVED_MIGRATIONS = [
    '20090714132448_create_hosts.rb',
    '20090714132449_add_audits_table.rb',
    '20090715143858_create_architectures.rb',
    '20090717025820_create_media.rb',
    '20090718060746_create_domains.rb',
    '20090718064254_create_subnets.rb',
    '20090720134126_create_operatingsystems.rb',
    '20090722140138_create_models.rb',
    '20090722141107_create_environments.rb',
    '20090729132209_create_reports.rb',
    '20090730152224_create_ptables.rb',
    '20090802062223_create_puppetclasses.rb',
    '20090804130144_create_parameters.rb',
    '20090820130541_create_auth_sources.rb',
    '20090905150131_create_hostgroups.rb',
    '20090905155444_add_type_to_parameter.rb',
    '20090907045751_add_domain_to_parameter.rb',
    '20090915030726_change_report_field_type_to_text.rb',
    '20090916053824_change_host_build_default_to_false.rb',
    '20090920043521_add_index_to_host.rb',
    '20090920064156_add_index_to_parameters.rb',
    '20090920065522_add_index_to_reports.rb',
    '20091012135004_create_users.rb',
    '20091016031017_create_sessions.rb',
    '20091022054108_add_status_to_report.rb',
    '20091214045923_calc_existing_reports.rb',
    '20091219132338_create_lookup_keys.rb',
    '20091219132839_create_lookup_values.rb',
    '20100115021803_change_mysql_reports_column.rb',
    '20100310080727_add_family_to_os.rb',
    '20100325142616_update_fact_names_and_values_to_bin.rb',
    '20100414125652_add_releasename_to_os.rb',
    '20100416124600_create_usergroups.rb',
    '20100419151910_add_owner_to_hosts.rb',
    '20100523114430_add_ubuntu_custom_lvm_ptable.rb',
    '20100523141204_create_media_operatingsystems_and_migrate_data.rb',
    '20100524080302_migrate_installation_medium_uri.rb',
    '20100525094200_simplify_parameters.rb',
    '20100601221000_update_os_minor.rb',
    '20100616114400_change_family_in_os.rb',
    '20100625155400_create_notices.rb',
    '20100628123400_add_internal_auth.rb',
    '20100629093200_create_roles.rb',
    '20100701081235_add_user_domains_and_hostgroups.rb',
    '20100822072954_create_user_facts.rb',
    '20100823181036_add_enabled_to_hosts.rb',
    '20100914092104_add_my_booleans_to_user.rb',
    '20101018120548_create_messages.rb',
    '20101018120603_create_sources.rb',
    '20101018120621_create_logs.rb',
    '20101019122857_add_metrics_to_report.rb',
    '20101019183859_convert_reports.rb',
    '20101103150254_add_owned_filter_to_user.rb',
    '20101118130026_correct_media.rb',
    '20101121080425_create_config_templates.rb',
    '20101121135521_create_template_combinations.rb',
    '20101122132041_create_operatingsystems_config_templates.rb',
    '20101123152150_create_template_kinds.rb',
    '20101123153303_create_os_default_templates.rb',
    '20101125153351_add_default_templates.rb',
    '20101130093613_add_sub_systems_to_subnet.rb',
    '20101130100315_create_proxies.rb',
    '20101202104444_add_proxy_to_domain.rb',
    '20101213085232_add_grubby_template.rb',
    '20110117162722_add_host_group_defaults.rb',
    '20110128130239_add_default_pxe_menu_template.rb',
    '20110213104226_create_proxy_features.rb',
    '20110216101848_change_puppetmaster_column.rb',
    '20110301154453_add_managed_to_hosts.rb',
    '20110321070954_revert_face_names_and_values_to_text_records.rb',
    '20110327123639_add_priority_to_parameter.rb',
    '20110404150043_add_media_path_to_medium.rb',
    '20110407091150_add_image_to_host.rb',
    '20110412103238_remove_unused_fields_from_puppet_classes.rb',
    '20110417102947_add_table_bookmarks.rb',
    '20110420150600_add_solaris_templates.rb',
    '20110613141800_add_solaris_disks.rb',
    '20110616080444_add_look_up_key_id_to_puppet_class.rb',
    '20110617190131_add_sparc_info_to_model.rb',
    '20110619130336_add_ancestry_to_hostgroup.rb',
    '20110628115422_create_settings.rb',
    '20110712064120_update_audits_table.rb',
    '20110712070522_create_host_class.rb',
    '20110725142054_add_suse_templates.rb',
    '20110801090318_add_vm_defaults_to_hostgroup.rb',
    '20110803114134_add_subnet_and_domain_to_host_groups.rb',
    '20111124095053_rename_changes_to_audited_changes.rb',
    '20111124095054_add_remote_address_to_audits.rb',
    '20111124095055_rename_parent_to_association.rb',
    '20111205231500_add_gateway_and_dns_to_subnets.rb',
    '20111227095806_ensure_all_hostnames_are_lowercase.rb',
    '20120102071633_add_from_and_to_ranges_to_subnets.rb',
    '20120110113051_create_subnet_domain.rb',
    '20120122131037_create_compute_resources.rb',
    '20120126113850_add_uuid_and_compute_id_to_host.rb',
    '20120127141602_add_windows_templates.rb',
    '20120311081257_create_nics.rb',
    '20120313081913_add_puppet_master_proxy_to_host_and_host_group.rb',
    '20120502105518_update_report_field_to_large_int.rb',
    '20120506143325_create_images.rb',
    '20120509131302_add_cert_name_to_host.rb',
    '20120510113417_create_key_pairs.rb',
    '20120521142924_add_dns_id_to_subnet.rb',
    '20120523065531_add_image_id_to_host.rb',
    '20120529113900_add_user_compute_resources.rb',
    '20120529115814_add_compute_resources_boolean_to_user.rb',
    '20120604114049_add_epel_snippets.rb',
    '20120607074318_convert_params_to_text.rb',
    '20120612070100_change_bookmark_column_to_text.rb',
    '20120613082125_rename_association_to_associated.rb',
    '20120620124658_fix_auditable_type.rb',
    '20120620124659_fix_associated_type.rb',
    '20120621135042_create_taxonomies.rb',
    '20120623002052_add_ok_hosts_book_mark.rb',
    '20120624081510_add_auditable_name_and_associated_name_to_audit.rb',
    '20120624093958_add_os_family_to_media.rb',
    '20120624094034_add_os_family_to_ptable.rb',
    '20120705130038_add_attributes_to_compute_resources.rb',
    '20120824142048_add_some_indexes.rb',
    '20120905095532_create_environment_classes.rb',
    '20120905131841_add_lookup_keys_override_and_required.rb',
    '20120916080843_add_lookup_values_count_to_lookup_keys.rb',
    '20120916080926_cache_lookup_values_count.rb',
    '20120921000313_add_iam_role_to_images.rb',
    '20120921105349_create_tokens.rb',
    '20120927020752_add_bmc_feature_to_proxy.rb',
    '20121003172526_add_taxonomy_ids_to_hosts.rb',
    '20121011115320_change_domain_character_count.rb',
    '20121015113502_update_media_path_limit.rb',
    '20121018152459_create_hostgroup_classes.rb',
    '20121026160433_add_localboot_template.rb',
    '20121029164911_rename_reply_adress_setting.rb',
    '20121101141448_add_locations_organizations.rb',
    '20121118120028_migrate_hypervisors_to_compute_resources.rb',
    '20121118125341_create_taxable_taxonomies.rb',
    '20121119102104_add_my_taxonomy_to_user.rb',
    '20121210214810_add_subscribe_to_all_hostgroups_to_users.rb',
    '20121218084123_change_smart_variable_length.rb',
    '20121219040534_remove_replay_address_setting.rb',
    '20130109155024_add_ignore_types_to_taxonomy.rb',
    '20130121130826_add_digest_to_messages.rb',
    '20130211160200_add_sti_to_hosts.rb',
    '20130228145456_add_digest_to_sources.rb',
    '20130329195742_remove_duplicate_snippets.rb',
    '20130409081924_add_label_to_host_group.rb',
    '20130417110127_add_sti_to_settings.rb',
    '20130418134513_fix_sti_host_auditable_type.rb',
    '20130419145808_add_id_to_user_hostgroup.rb',
    '20130430150500_add_locale_to_users.rb',
    '20130520152000_remove_duplicate_fact_names.rb',
    '20130520161514_add_unique_constraint_to_fact_name.rb',
    '20130523131455_add_unique_constraints_to_fact_values.rb',
    '20130530061844_change_column_lengths.rb',
    '20130625113217_add_templates_to_features.rb',
    '20130725081334_remove_environment_from_host.rb',
    '20130804131949_add_public_to_key_pairs.rb',
    '20130813105054_change_compute_resource_password_to_text.rb',
    '20130814132531_add_ldap_filter_to_auth_sources.rb',
    '20130908100439_delete_orphaned_records.rb',
    '20130908170524_add_keys.rb',
    '20130924145800_remove_unused_role_fields.rb',
    '20131003143143_fix_auditable_type2.rb',
    '20131014133347_add_compose_flag_and_short_name_to_fact_name.rb',
    '20131017142515_allow_null_values_on_fact_value.rb',
    '20131021125612_add_type_to_fact_name.rb',
    '20131021152315_change_name_index_on_fact_name.rb',
    '20131104132542_update_foreman_url.rb',
    '20131107094849_add_ancestry_to_fact_names.rb',
    '20131114084718_extend_user_role.rb',
    '20131114094841_create_cached_user_roles.rb',
    '20131122093940_calculate_cache_for_user_role.rb',
    '20131122150434_add_pxegrub_localboot_template.rb',
    '20131122170726_create_cached_usergroup_members.rb',
    '20131125230654_create_realms.rb',
    '20131127112625_rename_seeded_templates.rb',
    '20131128150357_add_admin_flag_to_usergroup.rb',
    '20131202120621_create_permissions.rb',
    '20131202131847_create_filters.rb',
    '20131202144415_create_filterings.rb',
    '20131204174455_add_description_to_operatingsystem.rb',
    '20131212125626_add_ldap_avatar_support.rb',
    '20131223120945_add_userdata_flag_to_images.rb',
    '20131224153518_create_compute_profiles.rb',
    '20131224153743_create_compute_attributes.rb',
    '20131224154836_add_compute_profile_to_hostgroup.rb',
    '20140110164135_add_foreign_keys_to_filters_and_filterings.rb',
    '20140115130443_add_password_to_images.rb',
    '20140123185537_add_default_organization_id_to_users.rb',
    '20140123194519_add_default_location_id_to_users.rb',
    '20140128123153_add_ancestry_to_taxonomies.rb',
    '20140219183342_change_label_to_title.rb',
    '20140219183343_migrate_permissions.rb',
    '20140219183345_add_taxonomy_searches_to_filter.rb',
    '20140304184854_add_provision_method_to_hosts.rb',
    '20140314004243_add_counter_caches.rb',
    '20140318153157_fix_puppetclass_counters.rb',
    '20140318221513_change_host_managed_default_to_false.rb',
    '20140320000449_add_server_type_to_auth_source.rb',
    '20140320004050_add_groups_base_to_auth_source.rb',
    '20140325093623_add_lowerlogin_to_users.rb',
    '20140407161817_create_config_groups.rb',
    '20140407162007_create_config_group_classes.rb',
    '20140407162059_create_host_config_groups.rb',
    '20140409031625_create_external_usergroups.rb',
    '20140410134234_remove_subscribe_to_all_hostgroups_from_users.rb',
    '20140413123650_add_counters_to_config_groups.rb',
    '20140415032811_add_config_group_counter_defaults.rb',
    '20140415052549_cleanup_users_properties.rb',
    '20140415053029_remove_user_join_tables.rb',
    '20140522122215_add_hidden_value_to_parameter.rb',
    '20140623144932_fix_integer_settings.rb',
    '20140630114339_add_boot_mode_to_subnet.rb',
    '20140705173549_add_locked_and_default_and_vendor_to_config_template.rb',
    '20140707113214_remove_architecture_default.rb',
    '20140710132249_extract_nic_attributes.rb',
    '20140711142510_add_attributes_to_nic_base.rb',
    '20140716102950_add_managed_to_nics.rb',
    '20140716140436_change_auditable_name_column_to_text.rb',
    '20140725101621_add_primary_interface_to_hosts.rb',
    '20140728190218_add_ip_suggestion_to_subnets.rb',
    '20140805114754_add_unique_index_to_parameter.rb',
    '20140826104209_add_merge_overrides_and_avoid_duplicates_to_lookup_key.rb',
    '20140828111505_fix_counters.rb',
    '20140901115249_add_request_uuid_to_audits.rb',
    '20140902102858_convert_ipam_to_string.rb',
    '20140908082450_remove_signo_setting.rb',
    '20140908192300_change_nil_admin_users_to_false.rb',
    '20140910111148_add_bond_attributes_to_nic_base.rb',
    '20140910153654_move_host_nics_to_interfaces.rb',
    '20140912113254_add_password_hash_to_operatingsystem.rb',
    '20140912114124_add_grub_password_to_hosts.rb',
    '20140912145052_add_grub_password_to_hostgroup.rb',
    '20140915141937_add_should_use_puppet_default_to_lookup_value_and_key.rb',
    '20140928131124_add_title_to_os.rb',
    '20140928140206_create_widgets.rb',
    '20140929073150_create_mail_notifications.rb',
    '20140929073343_create_user_mail_notifications.rb',
    '20140930201523_add_mail_enabled_to_user.rb',
    '20141014131912_add_subscription_type_to_mail_notifications.rb',
    '20141015164522_remove_failed_report_setting.rb',
    '20141021105446_rename_subnet_name_to_unique.rb',
    '20141023114229_add_timezone_to_user.rb',
    '20141109131448_rename_hosts_count_column.rb',
    '20141110084848_fix_puppetclass_total_hosts.rb',
    '20141112165600_add_type_to_parameter_index.rb',
    '20141116131324_add_mail_query_to_user_mail_notification.rb',
    '20141117093914_add_queryable_to_mail_notification.rb',
    '20141120140051_remove_audit_user_fk.rb',
    '20141124055509_rename_smart_proxy_auth_related_settings.rb',
    '20141203082104_make_templates_default.rb',
    '20141217101211_add_compute_attributes_to_nics.rb',
    '20141225073211_add_description_to_taxonomies.rb',
    '20150114141626_actually_rename_smart_proxy_auth_related_settings.rb',
    '20150127085513_set_ptable_layout_to_text.rb',
    '20150212161904_move_description_fields_to_text.rb',
    '20150225124617_add_default_widgets.rb',
    '20150225131946_change_default_subnet_boot_mode.rb',
    '20150312144232_migrate_websockets_setting.rb',
    '20150428070436_add_index_to_logs_source_id.rb',
    '20150428110835_change_os_default_password_hash.rb',
    '20150508124600_copy_unmanaged_hosts_to_interfaces.rb',
    '20150514072626_add_type_to_config_template.rb',
    '20150514114044_migrate_ptables_to_templates.rb',
    '20150514121649_add_usergroup_sync_to_auth_sources.rb',
    '20150519142008_remove_total_hosts_audits.rb',
    '20150521121315_rename_config_template_to_provisioning_template.rb',
    '20150525081931_remove_duplicate_tokens.rb',
    '20150602153751_change_usergroup_name_to_be_required.rb',
    '20150604104449_remove_counter_cache_audits.rb',
    '20150605073820_fix_template_snippet_flag.rb',
    '20150605103059_assign_ptables_to_taxonomies.rb',
    '20150606065713_add_sti_to_lookup_keys.rb',
    '20150612105614_rename_taxonomy_ignored_type_to_provisioning_templates.rb',
    '20150612135546_create_host_status.rb',
    '20150614171717_rename_puppetclass_counters_for_lk_sti.rb',
    '20150616080015_create_core_template_input.rb',
    '20150618093433_remove_unused_fields_from_hosts.rb',
    '20150622090115_change_reported_at.rb',
    '20150705131449_add_type_to_reports.rb',
    '20150708070742_add_full_name_to_setting.rb',
    '20150713143226_add_unique_to_operatingsystems_title.rb',
    '20150714132601_remove_is_param.rb',
    '20150714140850_remove_new_from_compute_attributes.rb',
    '20150714151223_remove_chef_proxy.rb',
    '20150721131324_change_bookmark_report_controller.rb',
    '20150728122736_change_report_permissions.rb',
    '20150811170401_add_merge_default_to_lookup_key.rb',
    '20150819105725_add_lookup_value_match_to_host_and_hostgroup.rb',
    '20150827152730_add_options_to_core_template_input.rb',
    '20150917155300_update_host_status_status_field_int.rb',
    '20151009084350_drop_ptables.rb',
    '20151019174035_rename_domain_host_count.rb',
    '20151025120534_add_hidden_value_to_lookup_key.rb',
    '20151104100257_add_hosts_count_to_hostgroup.rb',
    '20151109152507_add_host_status_host_id_index.rb',
    '20151120153254_delete_bootable_interface.rb',
    '20151210143537_add_type_to_mail_notification.rb',
    '20151220093801_remove_spaces_from_smart_variable_key.rb',
    '20160127134031_add_advanced_to_core_template_input.rb',
    '20160201131211_add_expired_logs_to_smart_proxy.rb',
    '20160203110216_add_default_value_for_bookmark_public_field.rb',
    '20160215143900_add_subnet_domain_relation_constraints.rb',
    '20160225115638_remove_default_user_role.rb',
    '20160225131917_rename_anonymous_role.rb',
    '20160228140111_update_params_priority.rb',
    '20160307120453_remove_hostgroups_count_from_puppetclasses.rb',
    '20160308102459_remove_permissions_from_roles.rb',
    '20160315161936_add_encrypted_to_settings.rb',
    '20160317070258_add_view_params_to_filters_with_edit.rb',
    '20160404074723_downcase_display_types.rb',
    '20160414063050_add_sti_to_subnets.rb',
    '20160415134454_add_ipv6_to_hosts.rb',
    '20160415135858_add_ipv6_subnet.rb',
    '20160516070529_divide_lookup_key_permissions.rb',
    '20160527093031_limit_os_description.rb',
    '20160609092110_remove_nil_from_merge_override.rb',
    '20160616074718_remove_host_counter_cache.rb',
    '20160626085636_remove_puppet_counters.rb',
    '20160715131352_set_role_builtin_default.rb',
    '20160717125402_unify_permissions.rb',
    '20160719081324_change_templates_type_default.rb',
    '20160719095445_change_template_taxable_taxonomies_type.rb',
    '20160719100624_change_template_audits_type.rb',
    '20160725142557_add_pxe_loader_to_host.rb',
    '20160726085358_rename_lookup_value_use_puppet_default.rb',
    '20160727084256_add_description_to_user.rb',
    '20160727142242_add_pxe_loader_to_hostgroup.rb',
    '20160728095626_add_description_to_role.rb',
    '20160817125655_reset_override_params.rb',
    '20160818062936_rename_puppet_mail_notifications.rb',
    '20160818091420_add_override_flag_to_filter.rb',
    '20160831121418_rename_lookup_key_use_puppet_default.rb',
    '20160914125418_update_parameter_priorities.rb',
    '20160922144222_change_fact_name_to_puppet_fact_name.rb',
    '20160924213018_change_widget_names.rb',
    '20160927071039_create_notification_blueprints.rb',
    '20160927071147_create_notifications.rb',
    '20160927073233_create_notification_recipients.rb',
    '20161006070258_migrate_common_parameter_permissions.rb',
    '20161007115719_rename_ipmi_boot_permission.rb',
    '20161129091049_remove_puppet_doc_root_setting.rb',
    '20161205142618_delete_orphaned_smart_class_parameters.rb',
    '20161227082709_change_architecture_name_limit.rb',
    '20161227082721_change_usergroup_name_limit.rb',
    '20170109115157_fix_lookup_key_auditable_type.rb',
    '20170110113824_change_id_value_range.rb',
    '20170112175131_migrate_template_to_parameters_macros.rb',
    '20170118142654_add_auto_increment_to_bigint_ids.rb',
    '20170118154134_add_type_index_to_reports.rb',
    '20170127094357_add_caching_enabled_to_compute_resource.rb',
    '20170131142526_fix_builtin_roles.rb',
    '20170201135815_add_domain_to_compute_resources.rb',
    '20170209084517_add_actions_to_notification_blueprint.rb',
    '20170209113134_remove_unused_permissions.rb',
    '20170213154641_add_index_reports_on_host_id_type_id.rb',
    '20170214132230_create_ssh_keys.rb',
    '20170221075203_singularize_resource_type_for_permissions.rb',
    '20170221100747_add_origin_to_roles.rb',
    '20170221195674_tidy_current_roles.rb',
    '20170223114114_lock_seeded_templates.rb',
    '20170223161638_lock_seeded_roles.rb',
    '20170226193446_move_subject_to_notifications.rb',
    '20170228134258_add_clone_info_to_role.rb',
    '20170301155205_remove_widget_hide.rb',
    '20170306100129_add_message_to_notification.rb',
    '20170315154334_add_report_time_type_host_index.rb',
    '20170316142703_add_missing_indexes_to_notification.rb',
    '20170319131341_add_ancestry_name_index_on_fact_name.rb',
    '20170404134531_add_description_to_subnets.rb',
    '20170405065305_remove_image_password_audit.rb',
    '20170424131346_add_description_to_hostgroup.rb',
    '20170525112713_change_audited_changes_in_audits.rb',
    '20170604082313_add_compute_resource_to_hostgroup.rb',
    '20170606115344_change_lookup_key_path_to_text.rb',
    '20170608130132_add_use_netgroups_to_ldap_auth_source.rb',
    '20170610132326_create_personal_access_tokens.rb',
    '20170622011347_add_http_proxies.rb',
    '20170629080604_change_preseed_default_pxe_grub2_kind.rb',
    '20170815130257_add_index_to_ssh_keys.rb',
    '20170828114310_fix_taxable_taxonomies_template_types.rb',
    '20170911133318_drop_default_type_in_templates.rb',
    '20170920211135_fix_host_auditable_type.rb',
    '20171005114442_fix_taxable_taxonomies_template_types_unscoped.rb',
    '20171016202300_increase_fact_value_size.rb',
    '20171109095957_add_key_type_to_parameters.rb',
    '20171119094913_add_mtu_to_subnet.rb',
    '20171121082256_update_centos_installation_media.rb',
    '20171121111333_change_auth_source_resource_type.rb',
    '20171126131104_remove_duplicate_taxable_taxonomies.rb',
    '20171208113210_remove_use_gravatar_setting.rb',
    '20171213161035_add_indexes_on_images.rb',
    '20171225122601_add_version_to_auditable_index.rb',
    '20171231134017_change_vlan_to_int.rb',
    '20180102082705_add_taxonomy_index_to_hosts.rb',
    '20180111130853_add_config_reports_origin.rb',
    '20180119205740_change_user_timezone_empty_to_nil.rb',
    '20180123140634_remove_limit_ldap_filter.rb',
    '20180129143410_create_jwt_secrets.rb',
    '20180208053256_create_table_preferences.rb',
    '20180216094550_add_template_to_subnets.rb',
    '20180228132500_rename_trusted_hosts.rb',
    '20180305111232_add_build_errors_to_hosts.rb',
    '20180312080251_change_digests_limit.rb',
    '20180322102951_fix_provision_templates_auditable_type.rb',
    '20180403144853_convert_vm_attrs_to_hash.rb',
    '20180404082603_remove_v3_from_ovirt_cr_url.rb',
    '20180424080702_change_subnet_vlanid_size.rb',
    '20180601102951_fix_all_templates_auditable_type.rb',
    '20180613100703_add_type_to_token.rb',
    '20180625082051_remove_associations_from_ptable_snippets.rb',
    '20180702102759_remove_params_value_limit.rb',
    '20180705164601_remove_legacy_puppet_hostname_setting.rb',
    '20180705191153_add_upgrade_task.rb',
    '20180705230311_smart_proxy_capabilities.rb',
    '20180713154128_add_index_on_role_names.rb',
    '20180715202514_optimize_indices.rb',
    '20180720143228_set_default_authsource_external_setting.rb',
    '20180724062531_change_out_of_sync_default.rb',
    '20180724152638_adjust_puppet_out_of_sync_interval.rb',
    '20180806151925_add_subnet_name_unique_constraint.rb',
    '20180816110716_add_httpboot_do_subnet.rb',
    '20180816134832_cast_lookup_key_values.rb',
    '20180820072858_add_help_text_to_template_kinds.rb',
    '20180831115634_add_uniqueness_to_puppetclass_name.rb',
    '20180903154354_remove_modulepath_setting.rb',
    '20180904142922_add_nic_delay_to_subnet.rb',
    '20180918135943_change_default_pxe_items.rb',
    '20181001141138_ignore_taxonomies_for_audit_filters.rb',
    '20181023112532_add_environment_puppetclass_id.rb',
    '20181101101145_add_index_to_lookup_values.rb',
    '20181105061336_cast_key_types_and_values_in_parameters.rb',
    '20181116104823_fixed_ignore_taxonomies_for_audit_filters.rb',
    '20181224174419_add_index_to_environment_class_by_lookup_key_and_puppetclass.rb',
  ]

  def up
    # Before migrating, partial migrations should be detected
    versions = REMOVED_MIGRATIONS.map { |file| file[/\A\d+/] }
    migrated = SchemaMigration.where("version IN (?)", versions)
    migrated_versions = migrated.map(&:version)

    if versions != migrated_versions && (versions & migrated_versions).any?
      raise "Invalid database state; The database needs to be upgraded to at least #{REMOVED_MIGRATIONS.last} before upgrading"
    end

    # Real migration
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
