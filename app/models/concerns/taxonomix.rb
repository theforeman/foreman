module Taxonomix
  extend ActiveSupport::Concern
  include DirtyAssociations

  included do
    taxonomy_join_table = :taxable_taxonomies
    has_many taxonomy_join_table.to_sym, :dependent => :destroy, :as => :taxable
    has_many :locations, -> { where(:type => 'Location') },
             :through => taxonomy_join_table, :source => :taxonomy,
             :validate => false
    has_many :organizations, -> { where(:type => 'Organization') },
             :through => taxonomy_join_table, :source => :taxonomy,
             :validate => false
    after_initialize :set_current_taxonomy

    scoped_search :relation => :locations, :on => :name, :rename => :location, :complete_value => true
    scoped_search :relation => :locations, :on => :id, :rename => :location_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :relation => :organizations, :on => :name, :rename => :organization, :complete_value => true
    scoped_search :relation => :organizations, :on => :id, :rename => :organization_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

    dirty_has_many_associations :organizations, :locations

    validate :ensure_taxonomies_not_escalated, :if => Proc.new { User.current.nil? || !User.current.admin? }
  end

  module ClassMethods
    attr_accessor :which_ancestry_method, :which_location, :which_organization

    # default inner_method includes children (subtree_ids)
    def with_taxonomy_scope(loc = Location.current, org = Organization.current, inner_method = :subtree_ids)
      scope = block_given? ? yield : where(nil)
      return scope unless Taxonomy.enabled_taxonomies.present?
      self.which_ancestry_method = inner_method
      self.which_location        = Location.expand(loc) if SETTINGS[:locations_enabled]
      self.which_organization    = Organization.expand(org) if SETTINGS[:organizations_enabled]
      scope = scope_by_taxable_ids(scope)
      scope.readonly(false)
    end

    # default inner_method includes parents (path_ids)
    def with_taxonomy_scope_override(loc = nil, org = nil, inner_method = :path_ids)
      # need to .unscope in case default_scope {with_taxonomy_scope} overrides inner_method
      unscope(:where => :taxonomy).with_taxonomy_scope(loc, org, inner_method)
    end

    def used_taxonomy_ids
      used_location_ids + used_organization_ids
    end

    def used_location_ids
      enforce_default
      return [] unless which_location && SETTINGS[:locations_enabled]
      get_taxonomy_ids(which_location, which_ancestry_method)
    end

    def used_organization_ids
      enforce_default
      return [] unless which_organization && SETTINGS[:organizations_enabled]
      get_taxonomy_ids(which_organization, which_ancestry_method)
    end

    def get_taxonomy_ids(taxonomy, method)
      Array(taxonomy).map { |t| t.send(method) + t.ancestor_ids }.flatten.uniq
    end

    # default scope is not called if we just use #scoped therefore we have to enforce quering
    # to get correct default values
    def enforce_default
      self.where(nil).limit(0).all unless which_ancestry_method.present?
    end

    def taxable_ids(loc = which_location, org = which_organization, inner_method = which_ancestry_method)
      # Return everything (represented by nil), including objects without
      # taxonomies. This value should only be returned for admin users.
      return nil if any_context?(loc) && any_context?(org) &&
        User.current.try(:admin?)

      inner_ids_loc = inner_ids(loc, Location, inner_method) if SETTINGS[:locations_enabled]
      inner_ids_org = inner_ids(org, Organization, inner_method) if SETTINGS[:organizations_enabled]

      inner_ids = inner_ids_loc & inner_ids_org
      inner_ids ||= inner_ids_loc if !SETTINGS[:organization_enabled]
      inner_ids ||= inner_ids_org if !SETTINGS[:location_enabled]
      inner_ids ||= []

      if self == User
        # In the case of users we want the taxonomy scope to get both the users
        # of the taxonomy, admins, and the current user.
        inner_ids.concat(admin_ids)
        inner_ids << User.current.id if User.current.present?
      end

      inner_ids
    end

    # Returns the IDs available for the passed context.
    # Passing a nil or [] value as taxonomy equates to "Any context".
    # Any other value will be understood as 'IDs available in this taxonomy'.
    def inner_ids(taxonomy, taxonomy_class, inner_method)
      return unscoped.pluck("#{table_name}.id") if taxonomy_class.ignore?(to_s)
      return inner_select(taxonomy, inner_method) if taxonomy.present?

      if any_context?(taxonomy) && User.current.present?
        # Any available taxonomy to the current user
        return unscoped.pluck("#{table_name}.id") if User.current.admin?

        taxonomy_relation = taxonomy_class.to_s.underscore.pluralize
        any_context_taxonomies = User.current.public_send(:"#{taxonomy_relation}")
        return any_context_taxonomies.map(&:"#{table_name}").flatten.uniq.map(&:id)
      end

      [] # When no user is found, and the taxonomy is nil, return no IDs
    end

    def any_context?(taxonomy)
      taxonomy.blank?
    end

    # taxonomy can be either specific taxonomy object or array of these objects
    # it can also be an empty array that means all taxonomies (user is not assigned to any)
    def inner_select(taxonomy, inner_method = which_ancestry_method)
      # always include ancestor_ids in inner select
      conditions = { :taxable_type => self.base_class.name }
      if taxonomy.present?
        taxonomy_ids = get_taxonomy_ids(taxonomy, inner_method)
        conditions.merge!(:taxonomy_id => taxonomy_ids)
      end

      TaxableTaxonomy.where(conditions).uniq.pluck(:taxable_id).compact
    end

    def admin_ids
      User.unscoped.only_admin.pluck(:id) if self == User
    end

    def scope_by_taxable_ids(scope)
      case (cached_ids = taxable_ids)
      when nil
        scope
      when []
        # If *no* taxable ids were found, then don't show any resources
        scope.where(:id => [])
      else
        # We need to generate the WHERE part of the SQL query as a string,
        # otherwise the default scope would set id on each new instance
        # and the same taxable_id on taxable_taxonomy objects
        scope.where("#{self.table_name}.id IN (#{cached_ids.join(',')})")
      end
    end
  end

  def set_current_taxonomy
    if self.new_record? && self.errors.empty?
      self.locations     << Location.current     if add_current_location?
      self.organizations << Organization.current if add_current_organization?
    end
  end

  def add_current_organization?
    add_current_taxonomy?(:organization)
  end

  def add_current_location?
    add_current_taxonomy?(:location)
  end

  def add_current_taxonomy?(taxonomy)
    klass, association = case taxonomy
                           when :organization
                             [Organization, :organizations]
                           when :location
                             [Location, :locations]
                           else
                             raise ArgumentError, "unknown taxonomy #{taxonomy}"
                         end
    current_taxonomy = klass.current
    Taxonomy.enabled?(taxonomy) && current_taxonomy && !self.send(association).include?(current_taxonomy)
  end

  def used_location_ids
    used_taxonomy_ids(:location_id)
  end

  def used_organization_ids
    used_taxonomy_ids(:organization_id)
  end

  def used_or_selected_location_ids
    (location_ids + used_location_ids).uniq
  end

  def used_or_selected_organization_ids
    (organization_ids + used_organization_ids).uniq
  end

  def children_of_selected_location_ids
    children_of_selected_taxonomy_ids(:locations)
  end

  def children_of_selected_organization_ids
    children_of_selected_taxonomy_ids(:organizations)
  end

  # Only administrator can choose empty taxonomies or taxonomies that they aren't assigned to,
  # other users can select only taxonomies they are granted to assign
  # and they can't leave the selection empty (which would mean global resource)
  #
  # we skip checking if user is global or it's not a new record and taxonomies were not changed
  # for existing records it would block saving global objects if taxonomies were not changed
  # for new records this would allow to create global objects for non global users
  def ensure_taxonomies_not_escalated
    taxonomies = []
    taxonomies << Organization if SETTINGS[:organizations_enabled]
    taxonomies << Location if SETTINGS[:locations_enabled]

    taxonomies.each do |taxonomy|
      assoc_base = taxonomy.to_s.downcase
      assoc = assoc_base.pluralize
      key = assoc_base + '_ids'

      next if (User.current.nil? || User.current.send(assoc.to_s).empty?) || (!new_record? && !self.send("#{key}_changed?"))

      allowed = taxonomy.authorized("assign_#{assoc}", taxonomy).pluck(:id).to_set.union(self.send("#{key}_was"))
      tried = self.send(key).to_set

      if tried.empty? || !tried.subset?(allowed)
        errors.add key, _('Invalid %s selection, you must select at least one of yours') % _(assoc)
      end
    end
  end

  protected

  def taxonomy_foreign_key_conditions
    if self.respond_to?(:taxonomy_foreign_conditions)
      taxonomy_foreign_conditions
    else
      { "#{self.class.base_class.to_s.tableize.singularize}_id".to_sym => id }
    end
  end

  def used_taxonomy_ids(type)
    return [] if new_record? || !self.respond_to?(:hosts)
    Host::Base.where(taxonomy_foreign_key_conditions).uniq.pluck(type).compact
  end

  def children_of_selected_taxonomy_ids(assoc)
    return [] if new_record?
    ids = []
    send(assoc).each do |tax|
      ids << tax.descendant_ids
    end
    ids.flatten.compact.uniq
  end
end
