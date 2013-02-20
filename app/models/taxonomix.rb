module Taxonomix
  def self.included(base)
    base.send :include, InstanceMethods

    base.class_eval do
      taxonomy_join_table = "taxable_taxonomies"
      has_many taxonomy_join_table, :dependent => :destroy, :as => :taxable
      has_many :locations,     :through => taxonomy_join_table, :source => :taxonomy,
               :conditions => "taxonomies.type='Location'", :validate => false
      has_many :organizations, :through => taxonomy_join_table, :source => :taxonomy,
               :conditions => "taxonomies.type='Organization'", :validate => false
      after_initialize :set_current_taxonomy

      scoped_search :in => :locations, :on => :name, :rename => :location, :complete_value => true
      scoped_search :in => :organizations, :on => :name, :rename => :organization, :complete_value => true

      def self.with_taxonomy_scope
        scope =  block_given? ? yield : where('1=1')
        scope = scope.where("#{self.table_name}.id in (#{inner_select(Location.current.id)}) #{user_conditions}") if SETTINGS[:locations_enabled] && Location.current && !Location.current.ignore?(self.to_s)
        scope = scope.where("#{self.table_name}.id in (#{inner_select(Organization.current.id)}) #{user_conditions}") if SETTINGS[:organizations_enabled] and Organization.current && !Organization.current.ignore?(self.to_s)
        scope.readonly(false)
      end

      def self.inner_select taxonomy_id
        "SELECT taxable_id from taxable_taxonomies WHERE taxable_type = '#{self.name}' AND taxonomy_id in (#{taxonomy_id}) "
      end

      # I the case of users we want the taxonomy scope to get both the users of the taxonomy and admins.
      # This is done here and not in the user class because scopes cannot be chained with OR condition.
      def self.user_conditions
        sanitize_sql_for_conditions([" OR users.admin = ?", true]) if self == User
      end

    end
  end

  module InstanceMethods
    def set_current_taxonomy
      if self.new_record? && self.errors.empty?
        self.locations    << Location.current      if Taxonomy.locations_enabled and Location.current
        self.organizations << Organization.current if Taxonomy.organizations_enabled and Organization.current
      end
    end

    # overwrite location_ids & organization_ids, since *_ids with has_many polymorphic is not working in Rails in 3.0.x. It works in 3.2.11
    def location_ids
      locations.pluck(:id)
    end

    def organization_ids
      organizations.pluck(:id)
    end

  end

end
