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

        test "route #{path} should have a permission that grants access" do
          # Basic check for a filter presence, can't do advanced features (:only, skip_*)
          controller = "#{r.defaults[:controller]}_controller".classify.constantize
          filters    = controller.send(:_process_action_callbacks)

          # Pass if the controller deliberately only permit admins (e.g. SettingsController)
          if filters.select { |f| f.filter == :require_admin }.empty?
            assert_not_equal [], Foreman::AccessControl.permissions.select { |p| p.actions.include? path }
          end
        end
      end
    end
  end
end
