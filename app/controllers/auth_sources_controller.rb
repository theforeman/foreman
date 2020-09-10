class AuthSourcesController < ApplicationController
  def index
    @auth_sources = AuthSource.except_hidden
    @users = User.except_hidden.includes(:auth_source)
    @auth_source_ldaps = resource_base_search_and_page
  end

  private

  def model_of_controller
    @model_of_controller ||= AuthSourceLdap
  end

  def controller_permission
    'authenticators'
  end
end
