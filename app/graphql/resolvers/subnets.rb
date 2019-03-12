module Resolvers
  class Subnets < BaseResolver
    MODEL_CLASS = ::Subnet

    include Concerns::Collection
  end
end
