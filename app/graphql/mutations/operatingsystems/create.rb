module Mutations
  module Operatingsystems
    class Create < CreateMutation
      graphql_name 'CreateOperatingsystemMutation'
      description 'Creates a new operating system'

      include Common
    end
  end
end
