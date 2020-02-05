module Mutations
  module Media
    class Update < UpdateMutation
      graphql_name 'UpdateMediumMutation'
      description 'Updates a new installation medium'

      include Common
    end
  end
end
