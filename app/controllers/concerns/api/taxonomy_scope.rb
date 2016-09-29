module Api
  module TaxonomyScope
    extend ActiveSupport::Concern

    included do
      before_action :set_taxonomy_scope
    end

    def set_taxonomy_scope
      if SETTINGS[:locations_enabled] && params[:location_id].present?
        Location.current ||= @location = Location.my_locations.find_by_id(params[:location_id])
        unless @location
          not_found _("Location with id %{id} not found") % { :id => params[:location_id] }
          return false
        end
      end
      if SETTINGS[:organizations_enabled] && params[:organization_id].present?
        Organization.current ||= @organization = Organization.my_organizations.find_by_id(params[:organization_id])
        unless @organization
          not_found _("Organization with id %{id} not found") % { :id => params[:organization_id] }
          return false
        end
      end
    end
  end
end
