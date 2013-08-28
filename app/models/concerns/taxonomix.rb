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
    scoped_search :in => :organizations, :on => :name, :rename => :organization, :complete_value => true
  end

  module ClassMethods
    def with_taxonomy_scope
      scope =  block_given? ? yield : where('1=1')

      if SETTINGS[:locations_enabled] && !Location.ignore?(self.to_s)
        scope = if Location.current
          scope.where(
              "#{self.table_name}.id in (#{entity_ids_in_taxonomies(Location.current)}) #{user_conditions}")
        else
          scope.where(
              "#{self.table_name}.id in (#{entity_ids_in_taxonomies(Location.my_locations)}) or #{self.table_name}.id not in (#{entity_ids_not_in_taxonomy_type('Location')}) #{user_conditions}")
        end
      end

      if SETTINGS[:organizations_enabled] && !Organization.ignore?(self.to_s)
        scope = if Organization.current
          scope.where("#{self.table_name}.id in (#{entity_ids_in_taxonomies(Organization.current)}) #{user_conditions}")
        else
          scope.where("#{self.table_name}.id in (#{entity_ids_in_taxonomies(Organization.my_organizations)}) or #{self.table_name}.id not in (#{entity_ids_not_in_taxonomy_type('Organization')}) #{user_conditions}")
        end
      end
      scope.readonly(false)
    end

    def entity_ids_in_taxonomies taxonomy
      taxonomy_ids = Array.wrap(taxonomy).map(&:id).join(',')
      "SELECT taxable_id from taxable_taxonomies WHERE taxable_type = '#{self.name}' AND taxonomy_id in (#{taxonomy_ids}) "
    end

    def entity_ids_not_in_taxonomy_type type
      "SELECT taxable_id from taxable_taxonomies WHERE taxable_type = '#{self.name}' and taxonomy_id in (select id from taxonomies where type='#{type}')"
    end

    # I the case of users we want the taxonomy scope to get both the users of the taxonomy and admins.
    # This is done here and not in the user class because scopes cannot be chained with OR condition.
    def user_conditions
      sanitize_sql_for_conditions([" OR users.admin = ?", true]) if self == User
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

end
