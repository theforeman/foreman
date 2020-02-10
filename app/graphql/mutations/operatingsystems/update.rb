module Mutations
  module Operatingsystems
    class Update < UpdateMutation
      graphql_name 'UpdateOperatingsystemMutation'
      description 'Updates an operating system'

      include Common
    end
  end
end
