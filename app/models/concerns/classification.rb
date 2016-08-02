module Classification
  extend ActiveSupport::Concern

  included do
    scope :values_hash, ->(host) { Classification::ValuesHashQuery.values_hash(host, current_scope || default_scoped) }
    scope :inherited_values, ->(host) { Classification::ValuesHashQuery.inherited_values(host, current_scope || default_scoped) }
  end
end
