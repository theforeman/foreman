module Types
  class Bookmark < BaseObject
    description 'A bookmark'

    global_id_field :id
    field :name, String
    field :query, String
    field :controller, String
    field :public, Boolean

    belongs_to :owner, Types::UserOrUsergroupUnion
  end
end
