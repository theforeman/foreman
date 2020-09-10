module Mutations
  module Models
    class Delete < DeleteMutation
      graphql_name 'DeleteModelMutation'
      description 'Deletes a hardware model.'
    end
  end
end
