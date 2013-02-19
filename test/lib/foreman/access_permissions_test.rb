require 'test_helper'
require 'foreman/access_control'
require 'foreman/access_permissions'

# Permissions are added in AccessPermissions with lists of controllers and
# actions that they enable access to.  For non-admin users, we need to test
# that there are permissions available that cover every controller action, else
# it can't be delegated and this will lead to parts of the application that
# aren't functional for non-admin users.
#
# In particular, it's important that actions for AJAX requests are added to
# an appropriate permission so views using those requests function.
class AccessPermissionsTest < ActiveSupport::TestCase
  MAY_SKIP_REQUIRE_LOGIN = [
    "users/login", "users/logout", "home/status",

    # puppetmaster interfaces
    "fact_values/create", "reports/create",

    # Users may switch taxonomies
    "locations/clear", "locations/select", "organizations/clear", "organizations/select",

    # TODO: list of actions that should be assigned to or have permissions created
    "audits/create", "audits/destroy", "audits/edit", "audits/new", "audits/update",
    "compute_resources/test_connection",
    "compute_resources_vms/console", "compute_resources_vms/edit", "compute_resources_vms/new", "compute_resources_vms/update",
    "config_templates/build_pxe_default",
    "facts/index", "facts/show",
    "hostgroups/nest",
    "hosts/multiple_puppetrun", "hosts/submit_multiple_enable", "hosts/update_multiple_puppetrun",
    "hosts/pending", "hosts/puppetrun", "hosts/pxe_config", "hosts/show_search", "hosts/storeconfig_klasses",
    "images/create", "images/destroy", "images/edit", "images/index", "images/new", "images/show", "images/update",
    "locations/assign_all_hosts", "locations/assign_hosts", "locations/assign_selected_hosts",
    "locations/clone_taxonomy", "locations/import_mismatches", "locations/mismatches", "locations/step2",
    "organizations/assign_all_hosts", "organizations/assign_hosts", "organizations/assign_selected_hosts",
    "organizations/clone_taxonomy", "organizations/import_mismatches", "organizations/mismatches", "organizations/step2",
    "lookup_values/create", "lookup_values/destroy", "lookup_values/index", "lookup_values/update",
    "notices/destroy",
    "operatingsystems/bootfiles",
    "puppetclasses/obsolete_and_new",
    "subnets/create_multiple", "subnets/import",
    "trends/count"
  ]

  # For each controller action, verify it has a permission that grants access
  Rails.application.routes.routes.inject({}) do |routes, r|
    routes["#{r.defaults[:controller].gsub(/::/, "_").underscore}/#{r.defaults[:action]}"] = r if r.defaults[:controller]
    routes
  end.each do |path, r|
    # Skip if excluded from this test (e.g. user login)
    next if MAY_SKIP_REQUIRE_LOGIN.include? path

    # Basic check for a filter presence, can't do advanced features (:only, skip_*)
    controller = "#{r.defaults[:controller]}_controller".classify.constantize
    filters    = controller.send(:_process_action_callbacks)

    # Skip controllers that don't require logins (e.g. API)
    next if filters.select { |f| f.filter == :require_login }.empty?
    # Or that deliberately only permit admins (e.g. SettingsController)
    next unless filters.select { |f| f.filter == :require_admin }.empty?

    test "route #{path} should have a permission that grants access" do
      assert_not_equal [], Foreman::AccessControl.permissions.select { |p| p.actions.include? path }
    end
  end
end
