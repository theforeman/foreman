module Mutations
  module Bookmarks
    class Create < CreateMutation
      graphql_name 'CreateBookmarkMutation'
      description 'Creates a new bookmark'

      include Common
    end
  end
end
