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

  def set_current_taxonomy
    if self.new_record? && self.errors.empty?
      self.locations    << Location.current      if Taxonomy.locations_enabled and Location.current
      self.organizations << Organization.current if Taxonomy.organizations_enabled and Organization.current
    end
  end

  module ClassMethods
    def with_taxonomy_scope
      scope =  block_given? ? yield : where('1=1')
      scope = scope.where("#{self.table_name}.id in (#{inner_select(Location.current)}) #{user_conditions}") if SETTINGS[:locations_enabled] && Location.current && !Location.ignore?(self.to_s)
      scope = scope.where("#{self.table_name}.id in (#{inner_select(Organization.current)}) #{user_conditions}") if SETTINGS[:organizations_enabled] and Organization.current && !Organization.ignore?(self.to_s)
      scope.readonly(false)
    end

    def inner_select taxonomy
      taxonomy_ids = Array.wrap(taxonomy).map(&:id).join(',')
      "SELECT taxable_id from taxable_taxonomies WHERE taxable_type = '#{self.name}' AND taxonomy_id in (#{taxonomy_ids}) "
    end

    # I the case of users we want the taxonomy scope to get both the users of the taxonomy and admins.
    # This is done here and not in the user class because scopes cannot be chained with OR condition.
    def user_conditions
      sanitize_sql_for_conditions([" OR users.admin = ?", true]) if self == User
    end
  end
end
