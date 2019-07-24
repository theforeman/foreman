module Taxonomix
  extend ActiveSupport::Concern
  include DirtyAssociations
  TAXONOMY_JOIN_TABLE = :taxable_taxonomies

  included do
    has_many TAXONOMY_JOIN_TABLE, :dependent => :destroy, :as => :taxable
    has_many :locations, -> { where(:type => 'Location') },
             :through => TAXONOMY_JOIN_TABLE, :source => :taxonomy,
             :validate => false
    has_many :organizations, -> { where(:type => 'Organization') },
             :through => TAXONOMY_JOIN_TABLE, :source => :taxonomy,
             :validate => false
    after_initialize :set_current_taxonomy

    scoped_search :relation => :locations, :on => :name, :rename => :location, :complete_value => true, :only_explicit => true
    scoped_search :relation => :locations, :on => :id, :rename => :location_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :relation => :organizations, :on => :name, :rename => :organization, :complete_value => true, :only_explicit => true
    scoped_search :relation => :organizations, :on => :id, :rename => :organization_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

    dirty_has_many_associations :organizations, :locations
    audit_associations :organizations, :locations if self.respond_to? :audit_associations

    validate :ensure_taxonomies_not_escalated, :if => Proc.new { User.current.nil? || !User.current.admin? }
  end

  module ClassMethods
    attr_accessor :which_ancestry_method, :which_location, :which_organization, :which_taxonomy_ignored

    # default inner_method includes children (subtree_ids)
    def with_taxonomy_scope(loc = Location.current, org = Organization.current, inner_method = :subtree_ids, which_taxonomy_ignored = [])
      scope = block_given? ? yield : where(nil)
      self.which_ancestry_method = inner_method
      self.which_taxonomy_ignored = which_taxonomy_ignored
      if SETTINGS[:locations_enabled] && !which_taxonomy_ignored.include?(:location)
        self.which_location = Location.expand(loc)
      else
        self.which_location = nil
      end

      if SETTINGS[:organizations_enabled] && !which_taxonomy_ignored.include?(:organization)
        self.which_organization = Organization.expand(org)
      else
        self.which_organization = nil
      end
      scope = scope_by_taxonomy_ids(scope)
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

    def taxonomy_ids_in_taxable_taxonomy(loc = which_location, org = which_organization, inner_method = which_ancestry_method)
      result = { :loc_ids => nil, :org_ids => nil }
      return result if any_context?(loc) && any_context?(org) && User.current.try(:admin?)

      result[:loc_ids] = taxonomy_inner_ids(loc, Location, inner_method) unless which_taxonomy_ignored.include?(:location)
      result[:org_ids] = taxonomy_inner_ids(org, Organization, inner_method) unless which_taxonomy_ignored.include?(:organization)
      result
    end

    def taxonomy_inner_ids(taxonomy, taxonomy_class, inner_method)
      return [] unless User.current.present?
      return taxonomy_class.pluck(:id) if taxonomy_class.ignore?(to_s)
      return get_taxonomy_ids(taxonomy, inner_method) if taxonomy.present?
      # return everything if admin is in 'Any Context'
      # note this is intentionaly positioned after the taxonomy.present? check
      return taxonomy_class.pluck(:id) if User.current.admin?

      taxonomy_relation = taxonomy_class.to_s.underscore.pluralize
      User.current.taxonomy_and_child_ids(:"#{taxonomy_relation}")
    end

    def any_context?(taxonomy)
      taxonomy.blank?
    end

    def admin_ids
      User.unscoped.only_admin.pluck(:id) if self == User
    end

    def scope_by_taxonomy_ids(scope)
      case (cached_ids = taxonomy_ids_in_taxable_taxonomy)
      when ->(hash) { hash[:loc_ids].nil? && hash[:org_ids].nil? }
        # return everything for admin
        scope
      when ->(hash) { hash[:loc_ids].empty? && hash[:org_ids].empty? }
        # return nothing when there are no taxonomies for non-admin
        scope.none
      else
        apply_scope_joins(scope, cached_ids)
      end
    end

    def apply_scope_joins(scope, ids_hash)
      scope = scope_join_by(scope, ids_hash[:loc_ids], :by_loc)
      scope = scope_join_by(scope, ids_hash[:org_ids], :by_org)
      scope
    end

    def scope_join_by(scope, ids, table_alias)
      if ids.present?
        scope.joins("INNER JOIN taxable_taxonomies AS #{table_alias}
                       ON #{table_alias}.taxable_id = #{table_name}.id
                       AND #{table_alias}.taxable_type = '#{self}'")
             .where("#{table_alias}.taxonomy_id IN (#{ids.join(',')})")
      else
        scope
      end
    end
  end

  def set_current_taxonomy
    if self.new_record? && self.errors.empty?
      # we need to use _ids methods so that DirtyAssociations is correctly saved
      self.location_ids += [ Location.current.id ] if add_current_location?
      self.organization_ids += [ Organization.current.id ] if add_current_organization?
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
    current_taxonomy && !self.send(association).include?(current_taxonomy)
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
        errors.add key, _("Invalid %{assoc} selection, you must select at least one of yours and have '%{perm}' permission.") % { :assoc => _(assoc), :perm => "assign_#{assoc}" }
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
    Host::Base.where(taxonomy_foreign_key_conditions).distinct.pluck(type).compact
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
