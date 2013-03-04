module Api
  module TaxonomyScope
    extend ActiveSupport::Concern

    included do
      before_filter :set_taxonomy_scope
    end

    module InstanceMethods
      def set_taxonomy_scope
        Location.current ||= @location = Location.find_by_id(params[:location_id]) if SETTINGS[:locations_enabled]
        Organization.current ||= @organization = Organization.find_by_id(params[:organization_id]) if SETTINGS[:organizations_enabled]
      end
    end

  end
end
