require Rails.root + 'db/seeds.d/020-roles_list.rb'

# methods which are used in seeds and migrations
class SeedHelper
  class << self
    # Check if audits show an object was renamed or deleted
    # additional attributes may be specified for narrowing the scope but note
    # that it can be slow if there's high number of audits for the specified type
    def audit_modified?(type, name, attributes = {})
      audits = Audit.where(:auditable_type => type.base_class.name, :auditable_name => name)
      audits = audits_from_attributes(audits, attributes) if attributes.present?

      return true if audits.where(:action => :destroy).present?
      audits.where(:action => :update).each do |audit|
        return true if audit_changed(audit, name)
      end
      false
    end

    def audit_changed(audit, name)
      audit.audited_changes['name'].is_a?(Array) && audit.audited_changes['name'].first == name
    end

    def audits_from_attributes(audits, attributes)
      audits.where(:id => interesting_audits(audits, attributes).map(&:id))
    end

    def interesting_audits(audits, attributes)
      audits.select do |audit|
        attributes.all? do |attribute, value|
          changed_attribute = audit.audited_changes[attribute]
          (audit.action == 'update') ? changed_attribute.first == value : changed_attribute == value
        end
      end
    end

    def create_filters(role, collection)
      collection.group_by(&:resource_type).each do |resource, permissions|
        filter      = Filter.new
        filter.role = role

        permissions.each do |permission|
          filtering            = filter.filterings.build
          filtering.permission = permission
        end

        filter.save!
      end
    end

    def create_role(role_name, options, builtin, check_audit = true)
      description = options[:description]

      if (existing = Role.find_by_name(role_name))
        if existing.description != description
          existing.update_attribute :description, description
        end

        # to allow create roles without updating permission
        # the only usage we're aware of is in migration that cleans up custom roles in
        # 20170221195674_tidy_current_roles because permissions are not present yet at this time
        update_permissions = options[:update_permissions].nil? || options[:update_permissions]
        update_role_permissions(existing, options) if update_permissions

        return
      end

      return if check_audit && audit_modified?(Role, role_name) && (builtin == 0)

      role = Role.new(:name => role_name, :builtin => builtin, :description => description)
      if role.respond_to? :origin
        role.origin = "foreman"
        role.modify_locked = true
      end
      role.save!
      permissions = Permission.where(:name => options[:permissions])
      create_filters(role, permissions)
    end

    def update_role_permissions(role, options)
      desired_permissions = options[:permissions].map(&:to_s)
      existing_permissions = role.permissions.where(:name => PermissionsList.permissions.map(&:last)).pluck(:name)

      role.ignore_locking do
        missing_permissions = desired_permissions - existing_permissions
        if missing_permissions.present?
          role.add_permissions(missing_permissions, :save! => true)
        end

        extra_permissions = existing_permissions - desired_permissions
        if extra_permissions.present?
          role.remove_permissions!(extra_permissions)
        end
      end
    end
  end
end
