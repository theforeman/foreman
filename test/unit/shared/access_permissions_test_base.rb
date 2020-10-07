require 'foreman/access_control'
require 'foreman/access_permissions'

module AccessPermissionsTestBase
  extend ActiveSupport::Concern

  module ClassMethods
    def should_skip_path?(path, skipped_actions, skip_patterns)
      skipped_actions.include?(path) || skip_patterns.any? { |pattern| path =~ pattern }
    end

    def check_routes(app_routes, skipped_actions, skip_patterns: [/^(api\/v2\/)?(dummy|fake)_/])
      # For each controller action, verify it has a permission that grants access
      app_routes = app_routes.routes.each_with_object({}) do |r, routes|
        routes["#{r.defaults[:controller].gsub(/::/, '_').underscore}/#{r.defaults[:action]}"] = r if r.defaults[:controller]
      end

      app_routes.each do |path, r|
        # Skip if excluded from this test (e.g. user login)
        next if should_skip_path?(path, skipped_actions, skip_patterns)

        test "route #{path} should have a permission that grants access" do
          # Basic check for a filter presence, can't do advanced features (:only, skip_*)
          controller = "#{r.defaults[:controller]}_controller".classify.constantize
          filters    = controller.send(:_process_action_callbacks)

          # Pass if the controller only permit admins (e.g. SettingsController)
          next if filters.any? { |f| f.filter == :require_admin }

          # Pass if the controller deliberately skips login requirement
          next if controller < ApplicationController && filters.select { |f| f.filter == :require_login }.empty?

          assert_not_empty Foreman::AccessControl.permissions.select { |p| p.actions.include? path }, "permission for #{path} not found, check access_permissions.rb"
        end
      end
    end
  end
end
