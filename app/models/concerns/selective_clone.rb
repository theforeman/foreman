module SelectiveClone
  extend ActiveSupport::Concern

  included do
    cattr_accessor :cloned_parameters
    # don't use Hash.new { [] }. deep_clone tries to fetch other keys from this hash,
    # and gets confused if the value is an empty array.
    self.cloned_parameters = {}
    cloned_parameters[:include] = []
    cloned_parameters[:except] = []

    def self.include_in_clone(*attributes)
      cloned_parameters[:include] += attributes
    end

    def self.exclude_from_clone(*attributes)
      cloned_parameters[:except] += attributes
    end
  end

  def selective_clone
    deep_clone(cloned_parameters)
  end
end
