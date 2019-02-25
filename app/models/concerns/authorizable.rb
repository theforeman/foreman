module Authorizable
  extend ActiveSupport::Concern

  def check_permissions_after_save
    return true if Thread.current[:ignore_permission_check]

    authorizer = Authorizer.new(User.current)
    creation = self.saved_change_to_id?
    name = permission_name(creation ? :create : :edit)

    Foreman::Logging.logger('permissions').debug { "verifying the transaction by permission #{name} for class #{self.class}" }
    unless authorizer.can?(name, self, false)
      errors.add :base, _("You don't have permission %{name} with attributes that you have specified or you don't have access to specified organizations or locations") % { :name => name }

      # This is required in case the rollback happend, the instance must look like new record so that all url helpers work correctly. Rails don't rollback these attributes.
      if creation
        self.id = nil
        @new_record = true
      end

      # we need to rollback orchestration tasks if this object orchestrates something
      if self.class.included_modules.include?(Orchestration)
        self.send :fail_queue, self.queue
      end

      raise ActiveRecord::Rollback
    end
  end

  def authorized?(permission)
    return false if User.current.nil?
    User.current.can?(permission, self)
  end

  def permission_name(action)
    self.class.find_permission_name(action)
  end

  included do
    after_save :check_permissions_after_save
  end

  module ClassMethods
    # permission can be nil (therefore we use Proc instead of lambda)
    # same applies for resource class
    #
    # e.g.
    #   FactValue.authorized_as(user)
    #   FactValue.authorized_as(user, :view_facts)
    #   Host::Base.authorized_as(user, :view_hosts, Host)
    #
    # Or you may simply use authorized for User.current
    def authorized_as(user, permission, resource = nil)
      if user.nil?
        self.where('1=0')
      elsif user.admin?
        self.where(nil)
      else
        Authorizer.new(user).find_collection(resource || self, :permission => permission)
      end
    end

    # joins to another class, on which the authorization is applied
    #
    # permission can be nil (therefore we use Proc instead of lambda)
    #
    # e.g.
    #   Report.joins_authorized_as(user, Host, :view_hosts)
    #   Host.joins_authorized_as(user, Domain, :view_domains)
    #
    # Or you may simply use authorized for User.current
    #
    # The default scope of `resource` is NOT applied since it's a join, instead
    # any extra conditions can be given in `opts[:where]`.
    #
    def joins_authorized_as(user, resource, permission, opts = {})
      if user.nil?
        self.where('1=0')
      else
        Authorizer.new(user).find_collection(resource, {:permission => permission, :joined_on => self}.merge(opts))
      end
    end

    def allows_taxonomy_filtering?(taxonomy)
      scoped_search_definition&.fields&.has_key?(taxonomy.to_sym)
    end

    def allows_organization_filtering?
      allows_taxonomy_filtering?(:organization_id)
    end

    def allows_location_filtering?
      allows_taxonomy_filtering?(:location_id)
    end

    def authorized(permission = nil, resource = nil)
      authorized_as(User.current, permission, resource)
    end

    def joins_authorized(resource, permission = nil, opts = {})
      joins_authorized_as(User.current, resource, permission, opts)
    end

    def skip_permission_check
      original_value, Thread.current[:ignore_permission_check] = Thread.current[:ignore_permission_check], true
      yield
    ensure
      Thread.current[:ignore_permission_check] = original_value
    end

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
