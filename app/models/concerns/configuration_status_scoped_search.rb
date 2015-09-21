module ConfigurationStatusScopedSearch
  extend ActiveSupport::Concern

  module ClassMethods
    def scoped_search_status(status, options)
      options.merge!({ :offset => Report::METRIC.index(status.to_s), :word_size => Report::BIT_NUM })
      scoped_search options
    end
  end
end
