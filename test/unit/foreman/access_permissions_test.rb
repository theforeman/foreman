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

    # ApipieDSL
    "apipie_dsl/apipie_dsls/index",

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

    # skip Active Mailbox controllers
    "action_mailbox/ingresses/mailgun/inbound_emails/create", "action_mailbox/ingresses/mandrill/inbound_emails/create",
    "action_mailbox/ingresses/postmark/inbound_emails/create", "action_mailbox/ingresses/relay/inbound_emails/create",
    "action_mailbox/ingresses/sendgrid/inbound_emails/create", "rails/conductor/action_mailbox/inbound_emails/create",
    "rails/conductor/action_mailbox/inbound_emails/destroy", "rails/conductor/action_mailbox/inbound_emails/edit",
    "rails/conductor/action_mailbox/inbound_emails/index", "rails/conductor/action_mailbox/inbound_emails/new",
    "rails/conductor/action_mailbox/inbound_emails/show", "rails/conductor/action_mailbox/inbound_emails/update",
    "rails/conductor/action_mailbox/reroutes/create",

    # graphql
    "api/graphql/execute",

    # ping
    "api/v2/ping/ping"
  ]

  MAY_SKIP_AUTHORIZED = ["about/index", "react/index", "api/v2/ping/ping"]

  SPECIAL_PATH = ['api/v2/puppet_hosts/puppetrun']

  check_routes(Rails.application.routes, MAY_SKIP_REQUIRE_LOGIN + MAY_SKIP_AUTHORIZED + SPECIAL_PATH)
end
