module Queries
  class AuthorizedModelQuery
    def initialize(model_class:, user:)
      @model_class = model_class
      @user = user
    end

    def find_by(params)
      authorized_scope.find_by(id: params[:id])
    end

    def results(params = {})
      if params[:search]
        authorized_scope.search_for(params[:search], :order => params[:order])
      else
        authorized_scope.all
      end
    end

    private

    attr_reader :model_class, :user

    def authorized_scope
      return model_class unless model_class.respond_to?(:authorized)

      permission = model_class.find_permission_name(:view)
      model_class.authorized_as(user, permission, model_class)
    end
  end
end
