module Foreman
  class Plugin
    class RoleLock
      attr_reader :plugin_id

      def initialize(plugin_id)
        @plugin_id = plugin_id
      end

      def register_role(name, permissions, role_registry, description = '')
        User.as_anonymous_admin do
          role = process_role name, permissions, description
          role_registry.role_ids << role.id
        end
      end

      def process_role(name, permissions, description = '')
        role = Role.find_by :name => name
        if role
          role.update_column(:description, description) if role.description != description

          if role&.origin && role.permission_diff(permissions).present?
            return update_plugin_role_permissions role, permissions
          end

          if role&.permission_diff(permissions)&.empty?
            role.update_attribute :origin, @plugin_id if role.origin.empty?
            return role
          end

        end

        Role.without_auditing do
          rename_existing role, name if role
          create_plugin_role name, permissions, description
        end
      end

      def create_plugin_role(name, permissions, description = '')
        Role.ignore_locking do
          begin
            role = Role.create! :name => name, :origin => @plugin_id, :description => description
            role.add_permissions!(permissions)
          rescue ActiveRecord::RecordNotUnique
            role = Role.find_by_name(name)
          end
          role
        end
      end

      def update_plugin_role_permissions(role, permissions)
        Role.ignore_locking do
          missing_permissions = role.missing_permissions(permissions)
          role.add_permissions!(missing_permissions) unless missing_permissions.empty?
          extra_permissions = role.extra_permissions(permissions)
          role.remove_permissions!(*extra_permissions) unless extra_permissions.empty?
          role
        end
      end

      def rename_existing(role, original_name)
        prefix = "Customized"
        role_name = generate_name prefix, original_name
        candidate_roles = Role.where('name like ?', "#{role_name}%").order(:name => :desc)
        return role.update_attribute :name, role_name if candidate_roles.empty?
        last_role = candidate_roles.detect { |candidate_role| last_role_num candidate_role, role_name }
        last_num = last_role ? last_role_num(last_role, role_name) : 0
        role.update_attribute :name, generate_name(prefix, original_name, last_num + 1)
      end

      def generate_name(prefix, original_name, num = nil)
        new_name = "#{prefix} #{original_name}"
        num ? new_name << " #{num}" : new_name
      end

      def last_role_num(role, role_name)
        Integer(role.name.split("#{role_name} ").last) rescue false
      end
    end
  end
end
