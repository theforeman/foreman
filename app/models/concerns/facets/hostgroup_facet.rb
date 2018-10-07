require 'facets'

module Facets
  module HostgroupFacet
    extend ActiveSupport::Concern

    included do
      belongs_to :hostgroup, class_name: "::Hostgroup", foreign_key: :hostgroup_id
    end

    module ClassMethods
      def inherit_attributes(*attributes)
        attributes_to_inherit.concat(attributes).uniq!
      end

      def attributes_to_inherit
        @attributes_to_inherit ||= begin
          _, facet_config = Facets.find_facet_by_class(self, :hostgroup)
          if facet_config.has_host_configuration? && facet_config.host_configuration.model == self
            attribute_names - ['id', 'created_at', 'updated_at']
          else
            []
          end
        end
      end
    end

    def inherited_attributes
      attributes.slice(*self.class.attributes_to_inherit)
    end
  end
end
