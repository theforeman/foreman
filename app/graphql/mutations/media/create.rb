module Mutations
  module Media
    class Create < CreateMutation
      graphql_name 'CreateMediumMutation'
      description 'Creates a new installation medium'

      include Common
    end
  end
end
