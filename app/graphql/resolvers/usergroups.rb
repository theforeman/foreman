module Resolvers
  class Usergroups < BaseResolver
    MODEL_CLASS = ::Usergroup

    include Concerns::Collection
  end
end
