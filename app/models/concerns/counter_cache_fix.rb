# Fix for counter cache not being updated on related model updates.
# See: https://github.com/rails/rails/issues/9722
# TODO: remove when upgrading to Rails 4.x
# inspired by fix from http://stackoverflow.com/a/11569554/1091445

module CounterCacheFix
  extend ActiveSupport::Concern

  included do
    after_commit :update_counter_caches, :on => :update

    def update_counter_caches
      self.previous_changes.each do |key, (old_value, new_value)|
        if key =~ /_id/
          association = self.association(key.sub(/_id$/, '').to_sym)
          if association.options[ :counter_cache ]

            # in case of counter cache on STI, specify the :inverse_of option, otherwise, we might throw an error.
            # i.e. VariableLookupKey belongs to puppetclass, but the association name on the puppetclass is lookup_keys, not puppetclass_lookup_keys
            # thus, we define the correct name for the association to be derived.
            if association.options[:inverse_of].is_a?(Symbol)
              counter_name = association.options[:inverse_of]
            else
              counter_name = self.class.name.underscore.split("/")[0].pluralize.to_sym
            end

            association_name = counter_name.to_s.sub(/_count$/, "").to_sym
            association.klass.reset_counters(old_value, association_name) if old_value
            association.klass.reset_counters(new_value, association_name) if new_value
          end
        end
      end
    end
  end
end
