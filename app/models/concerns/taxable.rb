module Taxable
  extend ActiveSupport::Concern

  module ClassMethods
    def taxable(organization: true, location: true, join_table: :taxable_taxonomies)
      include DirtyAssociations
      extend Taxonomix::ClassMethods

      cattr_accessor :taxable_options
      self.taxable_options = { organization: organization, location: location, join_table: join_table }

      has_many join_table, :dependent => :destroy, :as => :taxable
      if location
        has_many :locations, -> { where(:type => 'Location') },
          :through => join_table, :source => :taxonomy,
          :validate => false

        scoped_search :relation => :locations, :on => :name, :rename => :location, :complete_value => true, :only_explicit => true
        scoped_search :relation => :locations, :on => :id, :rename => :location_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
      end
      if organization
        has_many :organizations, -> { where(:type => 'Organization') },
          :through => join_table, :source => :taxonomy,
          :validate => false

        scoped_search :relation => :organizations, :on => :name, :rename => :organization, :complete_value => true, :only_explicit => true
        scoped_search :relation => :organizations, :on => :id, :rename => :organization_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
      end
      after_initialize :set_current_taxonomy

      used_assoc = []
      used_assoc << :organizations if organization
      used_assoc << :locations if location

      dirty_has_many_associations *used_assoc
      audit_associations *used_assoc if respond_to? :audit_associations

      validate :ensure_taxonomies_not_escalated, :if => proc { User.current.nil? || !User.current.admin? }
    end
  end
end
