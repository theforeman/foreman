module Resolvers
  class Models < BaseResolver
    MODEL_CLASS = ::Model

    include Concerns::Collection
  end
end
