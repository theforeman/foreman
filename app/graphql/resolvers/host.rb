module Resolvers
  class Host < BaseResolver
    MODEL_CLASS = ::Host

    include Concerns::Record
  end
end
