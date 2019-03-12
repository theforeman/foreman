module Resolvers
  class Operatingsystem < BaseResolver
    MODEL_CLASS = ::Operatingsystem

    include Concerns::Record
  end
end
