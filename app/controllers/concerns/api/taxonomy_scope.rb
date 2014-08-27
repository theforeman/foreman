module Api
  module TaxonomyScope
    extend ActiveSupport::Concern

    included do
      before_filter :set_taxonomy_scope
    end

    def set_taxonomy_scope
      if SETTINGS[:locations_enabled]
        Location.current ||= @location = Location.find_by_id(params[:location_id])
      end
      if SETTINGS[:organizations_enabled]
        Organization.current ||= @organization = Organization.find_by_id(params[:organization_id])
      end
    end

  end
end
