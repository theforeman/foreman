module Foreman::Controller::FilterParameters
  extend ActiveSupport::Concern

  module ClassMethods
    def filter_parameters(*names)
      @filter_parameters = names
    end

    def filter_parameters_options
      @filter_parameters
    end
  end

  def process_action(*args)
    if needs_filtering?(request.filtered_parameters)
      request.filtered_parameters.merge!(filter.filter(request.filtered_parameters))
    end
    super
  end

  private

  def filter
    ActiveSupport::ParameterFilter.new(self.class.filter_parameters_options)
  end

  def needs_filtering?(params)
    if self.class.filter_parameters_options
      !(self.class.filter_parameters_options.map(&:to_s) & params.keys).empty?
    else
      false
    end
  end
end
