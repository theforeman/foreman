class ActiveRecord::Base
  extend Host::Hostmix
  include HasManyCommon
  include StripWhitespace
  include Parameterizable::ById
end

# Fixes the issue with custom counter cache column names
module ActiveRecord::Associations::Builder
  class BelongsTo < SingularAssociation
    def self.add_counter_cache_callbacks(model, reflection)
      cache_column = reflection.counter_cache_column

      model.after_create lambda { |record|
        record.belongs_to_counter_cache_after_create(reflection)
      }

      model.before_destroy lambda { |record|
        record.belongs_to_counter_cache_before_destroy(reflection)
      }

      #model.after_update lambda { |record|
      #  record.belongs_to_counter_cache_after_update(reflection)
      #}

      klass = reflection.class_name.safe_constantize
      klass.attr_readonly cache_column if klass && klass.respond_to?(:attr_readonly)
    end
  end
end

module ActiveRecord
  module Delegation # :nodoc:
    module DelegateCache
      def relation_delegate_class(klass) # :nodoc:
        initialize_relation_delegate_cache if @relation_delegate_cache.nil?
        @relation_delegate_cache[klass]
      end
    end
  end
end
