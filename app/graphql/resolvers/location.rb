module Resolvers
  class Location < BaseResolver
    MODEL_CLASS = ::Location

    include Concerns::Record
  end
end
