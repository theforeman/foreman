module Resolvers
  class Architecture < BaseResolver
    MODEL_CLASS = ::Architecture

    include Concerns::Record
  end
end
