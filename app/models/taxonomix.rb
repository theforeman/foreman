module Taxonomix
  def self.included(base)
    base.send :include, InstanceMethods

    base.class_eval do
      @taxonomy_join_table = "taxable_taxonomies"
      @primary_key = "taxable_id"
      has_many @taxonomy_join_table, :dependent => :destroy, :as => :taxable
      has_many :locations,     :through => @taxonomy_join_table, :source => :taxonomy, :class_name => 'Location'
      has_many :organizations, :through => @taxonomy_join_table, :source => :taxonomy, :class_name => 'Organization'
      after_initialize :set_current_taxonomy

      scoped_search :in => :locations, :on => :name, :rename => :location, :complete_value => true
      scoped_search :in => :organizations, :on => :name, :rename => :organization, :complete_value => true

      def self.with_taxonomy_scope
        scope =  block_given? ? yield : where(1)

        scope = scope.where("#{self.table_name}.id in (#{inner_select(Location.current.id)})") if SETTINGS[:locations_enabled] and Location.current
        scope = scope.where("#{self.table_name}.id in (#{inner_select(Organization.current.id)})") if SETTINGS[:organizations_enabled] and Organization.current

        scope.readonly(false)
      end

      def self.inner_select taxonomy_id
        "SELECT taxable_id from taxable_taxonomies WHERE taxable_type = '#{self.name}' AND taxonomy_id in (#{taxonomy_id}) "
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

  end

end
