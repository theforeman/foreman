module Resolvers
  class Operatingsystems < BaseResolver
    MODEL_CLASS = ::Operatingsystem

    include Concerns::Collection
  end
end
