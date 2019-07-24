module TaxableCompute
  extend ActiveSupport::Concern
  include Taxonomix

  module ClassMethods
    def taxable_type
      'ComputeResource'
    end
  end

  included do
    # with proc support, default_scope can no longer be chained
    # include all default scoping here
    default_scope lambda {
      with_taxonomy_scope do
        order("compute_resources.name")
      end
    }
  end
end
