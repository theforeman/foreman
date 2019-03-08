module Resolvers
  class Locations < BaseResolver
    MODEL_CLASS = ::Location

    include Concerns::Collection
  end
end
