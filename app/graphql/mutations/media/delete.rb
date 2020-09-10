module Mutations
  module Media
    class Delete < DeleteMutation
      graphql_name 'DeleteMediumMutation'
      description 'Deletes an installation medium.'
    end
  end
end
