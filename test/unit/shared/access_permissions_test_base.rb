require 'foreman/access_control'
require 'foreman/access_permissions'

module AccessPermissionsTestBase
  extend ActiveSupport::Concern

  module ClassMethods
    def check_routes(app_routes, skipped_actions)
      # For each controller action, verify it has a permission that grants access
      app_routes = app_routes.routes.inject({}) do |routes, r|
        routes["#{r.defaults[:controller].gsub(/::/, '_').underscore}/#{r.defaults[:action]}"] = r if r.defaults[:controller]
        routes
      end

      app_routes.each do |path, r|
        # Skip if excluded from this test (e.g. user login)
        next if (skipped_actions).include? path

        # Basic check for a filter presence, can't do advanced features (:only, skip_*)
        begin
          controller = "#{r.defaults[:controller]}_controller".classify.constantize
          filters    = controller.send(:_process_action_callbacks)
        rescue NameError
          test "Could not constantize #{path}" do
            assert false
          end
          next
        end

        # Or that deliberately only permit admins (e.g. SettingsController)
        next unless filters.select { |f| f.filter == :require_admin }.empty?

        test "route #{path} should have a permission that grants access" do
          assert_not_equal [], Foreman::AccessControl.permissions.select { |p| p.actions.include? path }
        end
      end
    end
  end
end
