module Resolvers
  class Model < BaseResolver
    MODEL_CLASS = ::Model

    include Concerns::Record
  end
end
