module Types
  class Meta < GraphQL::Schema::Object
    field :can_destroy, Boolean, :null => false
    field :can_edit, Boolean, :null => false
  end
end
