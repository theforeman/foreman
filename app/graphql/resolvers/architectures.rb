module Resolvers
  class Architectures < BaseResolver
    MODEL_CLASS = ::Architecture

    include Concerns::Collection
  end
end
