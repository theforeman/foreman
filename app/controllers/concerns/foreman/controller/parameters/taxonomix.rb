module Foreman::Controller::Parameters::Taxonomix
  extend ActiveSupport::Concern

  class_methods do
    def add_taxonomix_params_filter(filter)
      add_taxonomix_attrs_params_filter(filter).permit :locations => [], :organizations => []
      filter
    end

    def add_taxonomix_attrs_params_filter(filter)
      add_organization_attrs_params_filter(filter)
      add_location_attrs_params_filter(filter)
      filter
    end

    def add_organization_attrs_params_filter(filter)
      filter.permit :organization_ids => [], :organization_names => []
    end

    def add_location_attrs_params_filter(filter)
      filter.permit :location_ids => [], :location_names => []
      filter
    end

    def organization_params_filter(klass)
      Foreman::ParameterFilter.new(klass).tap do |filter|
        add_organization_attrs_params_filter(filter)
      end
    end

    def location_params_filter(klass)
      Foreman::ParameterFilter.new(klass).tap do |filter|
        add_location_attrs_params_filter(filter)
      end
    end
  end
end
