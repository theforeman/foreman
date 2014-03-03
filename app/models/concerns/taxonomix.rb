module Taxonomix
  extend ActiveSupport::Concern

  included do
    taxonomy_join_table = "taxable_taxonomies"
    has_many taxonomy_join_table, :dependent => :destroy, :as => :taxable
    has_many :locations,     :through => taxonomy_join_table, :source => :taxonomy,
             :conditions => "taxonomies.type='Location'", :validate => false
    has_many :organizations, :through => taxonomy_join_table, :source => :taxonomy,
             :conditions => "taxonomies.type='Organization'", :validate => false
    after_initialize :set_current_taxonomy

    scoped_search :in => :locations, :on => :name, :rename => :location, :complete_value => true
    scoped_search :in => :locations, :on => :id, :rename => :location_id, :complete_value => true
    scoped_search :in => :organizations, :on => :name, :rename => :organization, :complete_value => true
    scoped_search :in => :organizations, :on => :id, :rename => :organization_id, :complete_value => true
  end

  module ClassMethods

    attr_accessor :which_ancestry_method, :which_location, :which_organization

    # default inner_method includes children (subtree_ids)
    def with_taxonomy_scope(loc = Location.current, org = Organization.current, inner_method = :subtree_ids)
      self.which_ancestry_method = inner_method
      self.which_location        = loc
      self.which_organization    = org
      scope =  block_given? ? yield : where('1=1')
      scope = scope.where(:id => taxable_ids) if taxable_ids
      scope.readonly(false)
    end

    # default inner_method includes parents (path_ids)
    def with_taxonomy_scope_override(loc = nil, org = nil, inner_method = :path_ids)
      # need to .unscoped or default_scope {with_taxonomy_scope} overrides inner_method
      unscoped.with_taxonomy_scope(loc, org, inner_method)
    end

    def used_taxonomy_ids
      used_location_ids + used_organization_ids
    end

    def used_location_ids
      enforce_default
      return [] unless which_location && SETTINGS[:locations_enabled]
      (which_location.send(which_ancestry_method) + which_location.ancestor_ids).uniq
    end

    def used_organization_ids
      enforce_default
      return [] unless which_organization && SETTINGS[:organizations_enabled]
      (which_organization.send(which_ancestry_method) + which_organization.ancestor_ids).uniq
    end

    # default scope is not called if we just use #scoped therefore we have to enforce quering
    # to get correct default values
    def enforce_default
      if which_ancestry_method.nil?
        self.scoped.limit(0).all
      end
    end

    def taxable_ids(loc = which_location, org = which_organization, inner_method = which_ancestry_method)
      if SETTINGS[:locations_enabled] && loc
        inner_ids_loc = if Location.ignore?(self.to_s)
                          self.pluck(:id)
                        else
                          inner_select(loc, inner_method)
                        end
      end
      if SETTINGS[:organizations_enabled] && org
        inner_ids_org = if Organization.ignore?(self.to_s)
                          self.pluck(:id)
                        else
                          inner_select(org, inner_method)
                        end
      end
      inner_ids   = inner_ids_loc & inner_ids_org if (inner_ids_loc && inner_ids_org)
      inner_ids ||= inner_ids_loc if inner_ids_loc
      inner_ids ||= inner_ids_org if inner_ids_org
      # In the case of users we want the taxonomy scope to get both the users of the taxonomy and admins.
      inner_ids << admin_ids if inner_ids && self == User
      inner_ids
    end

    def inner_select(taxonomy, inner_method = which_ancestry_method)
      # always include ancestor_ids in inner select
      taxonomy_ids = (taxonomy.send(inner_method) + taxonomy.ancestor_ids).uniq
      TaxableTaxonomy.where(:taxable_type => self.name, :taxonomy_id => taxonomy_ids).pluck(:taxable_id).compact.uniq
    end

    def admin_ids
      User.unscoped.where(:admin => true).pluck(:id) if self == User
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

  protected

  def taxonomy_foreign_key_conditions
    if self.respond_to?(:taxonomy_foreign_conditions)
      taxonomy_foreign_conditions
    else
      { "#{self.class.base_class.to_s.tableize.singularize}_id".to_sym => id }
    end
  end

  def used_taxonomy_ids(type)
    return [] if new_record?
    Host::Base.where(taxonomy_foreign_key_conditions).pluck(type).uniq.compact
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
