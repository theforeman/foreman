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

        scope = scope.joins(taxonomy_join_condition 'loc1').where("loc1.taxonomy_id in (?)", Location.current.id) if SETTINGS[:locations_enabled] and Location.current
        scope = scope.joins(taxonomy_join_condition 'org1').where("org1.taxonomy_id in (?)", Organization.current.id) if SETTINGS[:organizations_enabled] and Organization.current

        scope
      end

      def self.taxonomy_join_condition name
        " INNER JOIN #{@taxonomy_join_table} #{name} ON #{name}.#{@primary_key} = #{self.table_name}.id and #{name}.taxable_type = '#{self.to_s}'"
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
