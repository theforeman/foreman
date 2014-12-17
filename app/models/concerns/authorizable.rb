module Authorizable
  extend ActiveSupport::Concern

  included do
    # permission can be nil (therefore we use Proc instead of lambda)
    # same applies for resource class
    #
    # e.g.
    #   FactValue.authorized_as(user)
    #   FactValue.authorized_as(user, :view_facts)
    #   Host::Base.authorized_as(user, :view_hosts, Host)
    #
    # Or you may simply use authorized for User.current
    #
    scope :authorized_as, Proc.new { |user, permission, resource|
      if user.nil?
        self.where('1=0')
      elsif user.admin?
        self.all
      else
        Authorizer.new(user).find_collection(resource || self, :permission => permission)
      end
    }

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
    scope :joins_authorized_as, Proc.new { |user, resource, permission, opts = {}|
      if user.nil?
        self.where('1=0')
      else
        Authorizer.new(user).find_collection(resource, {:permission => permission, :joined_on => self}.merge(opts) )
      end
    }

    def authorized?(permission)
      return false if User.current.nil?
      User.current.can?(permission, self)
    end
  end

  module ClassMethods
    def allows_taxonomy_filtering?(taxonomy)
      scoped_search_definition.fields.has_key?(taxonomy)
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
  end
end
