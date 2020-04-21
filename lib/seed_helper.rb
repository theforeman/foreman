require Rails.root + 'db/seeds.d/020-roles_list.rb'

# methods which are used in seeds and migrations
class SeedHelper
  class << self
    # Check if audits show an object was renamed or deleted
    # additional attributes may be specified for narrowing the scope but note
    # that it can be slow if there's high number of audits for the specified type
    def audit_modified?(type, name, attributes = {})
      audits = Audit.where(:auditable_type => type.base_class.name, :auditable_name => name)

      return true if filter_destroy_audits(audits.where(:action => :destroy), attributes).present?
      audits.where(:action => :update).each do |audit|
        return true if audit_changed(audit, name) && audited_matches_attributes?(audit, attributes)
      end
      false
    end

    def filter_destroy_audits(audits, attributes)
      return audits unless attributes.present?
      audits.select do |audit|
        attributes.all? do |attribute, value|
          audit.audited_changes[attribute] == value
        end
      end
    end

    def audited_matches_attributes?(audit, attributes)
      return true unless attributes.present?
      matching_attributes_on = audit.auditable
      matching_attributes_on ||= Audit.find_by(:auditable_type => audit.auditable_type, :auditable_id => audit.auditable_id, :action => :destroy)&.audited_changes
      matching_attributes_on.nil? || attributes.all? { |attr, val| matching_attributes_on[attr.to_s] == val }
    end

    def audit_changed(audit, name)
      audit.audited_changes['name'].is_a?(Array) && audit.audited_changes['name'].first == name
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

        # The built in role may have additional permissions added to it by users.
        # To remove permissions from the default role use an explicit migration.
        return if role.builtin == Role::BUILTIN_DEFAULT_ROLE

        extra_permissions = existing_permissions - desired_permissions
        if extra_permissions.present?
          role.remove_permissions!(extra_permissions)
        end
      end
    end

    def import_raw_template(contents, vendor = 'Foreman')
      metadata = Template.parse_metadata(contents)
      raise "Attribute 'name' is required in metadata in order to seed the template" if metadata['name'].nil?
      raise "Attribute 'model' is required in metadata in order to seed the template" if metadata['model'].nil?

      name = metadata['name']
      requirements = metadata['require'] || []

      begin
        model = metadata['model'].constantize
      rescue NameError
        logger.info("Unknown model #{metadata['model']} in template #{name}, skipping import.")
        return
      end

      # Skip templates with custom changes
      return if audit_modified?(model, name)
      # Skip templates that don't match requirements
      return unless test_template_requirements(name, requirements)

      t = model.import_without_save(name, contents, { :default => true, :lock => true, :associate => 'new' })
      t.vendor = vendor

      if !t.persisted?
        t.organizations = Organization.unscoped.all if t.respond_to?(:organizations=)
        t.locations = Location.unscoped.all if t.respond_to?(:locations=)
        raise "Unable to create template #{t.name}: #{format_errors t}" unless t.valid?
      else
        raise "Unable to update template #{t.name}: #{format_errors t}" unless t.ignore_locking { t.valid? }
      end

      t.ignore_locking { t.save! }
      t
    end

    def import_templates(template_paths, vendor = 'Foreman')
      template_paths.each do |path|
        import_raw_template(File.read(path), vendor)
      end
    end

    def partition_tables_templates
      Dir["#{Rails.root}/app/views/unattended/partition_tables_templates/*.erb"]
    end

    def provisioning_templates
      Dir["#{Rails.root}/app/views/unattended/provisioning_templates/**/*.erb"]
    end

    def report_templates
      Dir["#{Rails.root}/app/views/unattended/report_templates/*.erb"]
    end

    def format_errors(model = nil)
      return '(nil found)' if model.nil?
      model.errors.full_messages.join(';')
    end

    private

    def logger
      Foreman::Logging.logger('app')
    end

    def test_template_requirements(template_name, requirements)
      requirements.each do |r|
        plugin = Foreman::Plugin.find(r['plugin'])

        if plugin.nil?
          logger.info("Template #{template_name} requires plugin #{r['plugin']}, skipping import.")
          return false
        elsif r['version'] && (Gem::Version.new(plugin.version).release < Gem::Version.new(r['version']))
          logger.info("Template #{template_name} requires plugin #{r['plugin']} >= #{r['version']}, skipping import.")
          return false
        end
      end
      true
    end
  end
end
