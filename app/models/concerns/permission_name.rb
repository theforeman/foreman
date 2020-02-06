module PermissionName
  extend ActiveSupport::Concern

  def permission_name(action)
    self.class.find_permission_name(action)
  end

  module ClassMethods
    def find_permission_name(action)
      type = Permission.resource_name(self)
      permissions = Permission.where(:resource_type => type).where(["#{Permission.table_name}.name LIKE ?", "#{action}_%"])

      # some permissions are grouped for same resource, e.g. edit_comupute_resources and edit_compute_resources_vms, in such case we need to detect the right permission
      if permissions.size > 1
        permissions.detect { |p| p.name.end_with?(type.underscore.pluralize) }.try(:name)
      else
        permissions.first.try(:name)
      end
    end
  end
end
