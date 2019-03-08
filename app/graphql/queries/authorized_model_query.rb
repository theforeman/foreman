module Queries
  class AuthorizedModelQuery
    def initialize(model_class:, user:)
      @model_class = model_class
      @user = user
    end

    delegate :find_by, to: :authorized_scope

    def results(params = {})
      if params[:search].present?
        authorized_scope.search_for(*search_options(params))
      elsif params[:order_by].present?
        ordered_results(order_field: params[:order_by], order_direction: params[:order])
      else
        authorized_scope.all
      end
    end

    def find_by_global_id(global_id)
      id = Foreman::GlobalId.decode(global_id).last
      find_by(id: id)
    end

    private

    attr_reader :model_class, :user

    def authorized_scope
      return model_class unless model_class.respond_to?(:authorized)

      permission = model_class.find_permission_name(:view)
      model_class.authorized_as(user, permission, model_class)
    end

    def search_options(params)
      search_options = [params[:search]]
      if params[:order_by].present?
        search_options << { :order => "#{params[:order_by]} #{params[:order]}".strip }
      end
      search_options
    end

    def ordered_results(order_field:, order_direction:)
      order_direction = order_direction.presence || :ASC
      authorized_scope.order(order_field => order_direction).all
    end
  end
end
