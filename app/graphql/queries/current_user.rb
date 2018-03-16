class Queries::CurrentUser < GraphQL::Function
  type do
    name 'CURRENT_USER_PAYLOAD'

    field :user_id, types.ID
  end

  def call(obj, args, ctx)
    current_user = ctx[:current_user]
    return unless current_user

    OpenStruct.new(user_id: current_user.id)
  end
end
