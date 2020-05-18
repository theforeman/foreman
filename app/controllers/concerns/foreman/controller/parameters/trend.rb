module Foreman::Controller::Parameters::Trend
  extend ActiveSupport::Concern

  class_methods do
    def trend_params_filter
      Foreman::ParameterFilter.new(ForemanStatistics::Trend).tap do |filter|
        filter.permit :fact_value, :fact_name,
          :name,
          :trendable_type, :trendable_id,
          :type
      end
    end
  end

  def trend_params
    self.class.trend_params_filter.filter_params(params, parameter_filter_context)
  end
end
