module Resolvers
  class Usergroup < BaseResolver
    MODEL_CLASS = ::Usergroup

    include Concerns::Record
  end
end
