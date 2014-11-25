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
    "users/login", "users/logout", "users/extlogin", "users/extlogout", "home/status", "notices/destroy", "unattended/",

    # puppetmaster interfaces
    "fact_values/create", "reports/create",

    # Users may switch taxonomies
    "locations/clear", "locations/select", "organizations/clear", "organizations/select",

    # No controller action actually exists, shouldn't be permitted either
    "audits/create", "audits/destroy", "audits/edit", "audits/new", "audits/update",

    # Apipie
    "apipie/apipies/index", "apipie/apipies/apipie_checksum",

    # App controller stubs
    "testable/index", "api/testable/index", "api/testable/raise_error",
    "api/v2/testable/index", "api/v2/testable/create", "testable_strong_params/create",
    "my_hosts/create", "testable_no_params/create",

    # Content Security Policy report forwarding endpoint - noop if not configured.
    # See https://github.com/twitter/secureheaders/issues/113
    "content_security_policy/scribe"
  ]

  MAY_SKIP_AUTHORIZED = [ "about/index" ]

  # For each controller action, verify it has a permission that grants access
  Rails.application.routes.routes.inject({}) do |routes, r|
    routes["#{r.defaults[:controller].gsub(/::/, "_").underscore}/#{r.defaults[:action]}"] = r if r.defaults[:controller]
    routes
  end.each do |path, r|
    # Skip if excluded from this test (e.g. user login)
    next if (MAY_SKIP_AUTHORIZED + MAY_SKIP_REQUIRE_LOGIN).include? path

    # Basic check for a filter presence, can't do advanced features (:only, skip_*)
    controller = "#{r.defaults[:controller]}_controller".classify.constantize
    filters    = controller.send(:_process_action_callbacks)

    # Or that deliberately only permit admins (e.g. SettingsController)
    next unless filters.select { |f| f.filter == :require_admin }.empty?

    test "route #{path} should have a permission that grants access" do
      assert_not_equal [], Foreman::AccessControl.permissions.select { |p| p.actions.include? path }
    end
  end
end
