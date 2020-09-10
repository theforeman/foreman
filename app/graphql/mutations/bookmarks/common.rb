module Mutations
  module Bookmarks
    module Common
      extend ActiveSupport::Concern

      included do
        argument :name, String
        argument :query, String
        argument :controller, String
        argument :public, GraphQL::Types::Boolean, required: false

        field :bookmark, Types::Bookmark, 'The bookmark', null: true
      end
    end
  end
end
