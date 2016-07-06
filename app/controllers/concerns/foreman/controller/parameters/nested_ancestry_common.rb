module Foreman::Controller::Parameters::NestedAncestryCommon
  extend ActiveSupport::Concern

  class_methods do
    def add_nested_ancestry_common_params_filter(filter)
      filter.permit :parent, :parent_id
      filter
    end
  end
end
