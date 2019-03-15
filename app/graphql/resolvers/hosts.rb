module Resolvers
  class Hosts < BaseResolver
    MODEL_CLASS = ::Host

    include Concerns::Collection
  end
end
