module Types
  class UserOrUsergroupUnion < BaseUnion
    description 'A user or a usergroup'
    possible_types ::Types::User, ::Types::Usergroup
  end
end
