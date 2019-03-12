module Resolvers
  class Subnet < BaseResolver
    MODEL_CLASS = ::Subnet

    include Concerns::Record
  end
end
