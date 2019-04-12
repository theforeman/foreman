require 'test_helper'
require 'unit/shared/access_permissions_test_base'

# Permissions are added in AccessPermissions with lists of controllers and
# actions that they enable access to.  For non-admin users, we need to test
# that there are permissions available that cover every controller action, else
# it can't be delegated and this will lead to parts of the application that
# aren't functional for non-admin users.
#
# In particular, it's important that actions for AJAX requests are added to
# an appropriate permission so views using those requests function.
class AccessPermissionsTest < ActiveSupport::TestCase
  include AccessPermissionsTestBase

  MAY_SKIP_REQUIRE_LOGIN = [
    "users/login", "users/logout", "users/extlogin", "users/extlogout", "home/status", "notices/destroy",

    # unattended built and failed action is not for interactive use
    "unattended/built", "unattended/failed",

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
    "api/testable/required_nested_values", "api/testable/optional_nested_values", "api/testable/nested_values",
    "api/v2/testable/index", "api/v2/testable/create", "api/v2/testable/new", "fake/index", "api/v2/fake/index",

    # test stubs
    "testable_resources/index",

    # Content Security Policy report forwarding endpoint - noop if not configured.
    # See https://github.com/twitter/secureheaders/issues/113
    "content_security_policy/scribe",

    # table preferences. No special permissions comes with user
    "api/v2/table_preferences/index", "api/v2/table_preferences/show", "api/v2/table_preferences/create",
    "api/v2/table_preferences/update", "api/v2/table_preferences/destroy",

    # skip Active Storage controllers
    # https://github.com/rails/rails/issues/31228
    "active_storage/blobs/show", "active_storage/direct_uploads/create", "active_storage/disk/show",
    "active_storage/disk/update", "active_storage/previews/show", "active_storage/representations/show",
    "active_storage/variants/show",

    # graphql
    "api/graphql/execute"
  ]

  MAY_SKIP_AUTHORIZED = [ "about/index" ]

  SPECIAL_PATH = ['api/v2/puppet_hosts/puppetrun']

  check_routes(Rails.application.routes, MAY_SKIP_REQUIRE_LOGIN + MAY_SKIP_AUTHORIZED + SPECIAL_PATH)
end
