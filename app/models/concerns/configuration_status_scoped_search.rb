module ConfigurationStatusScopedSearch
  extend ActiveSupport::Concern

  module ClassMethods
    def scoped_search_status(status, options)
      options.merge!({ :offset => ConfigReport::METRIC.index(status.to_s), :word_size => ConfigReport::BIT_NUM })
      scoped_search options
    end
  end
end
