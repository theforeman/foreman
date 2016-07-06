module Foreman::Controller::Parameters::Widget
  extend ActiveSupport::Concern

  class_methods do
    def widget_params_filter
      Foreman::ParameterFilter.new(::Widget).tap do |filter|
        filter.permit :col,
          :hide,
          :row,
          :sizex,
          :sizey
      end
    end
  end
end
