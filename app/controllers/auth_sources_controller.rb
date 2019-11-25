class AuthSourcesController < ApplicationController
  def index
    @auth_sources = AuthSource.except_hidden
    @users = User.except_hidden.includes(:auth_source)
    @auth_source_ldaps = resource_base_search_and_page.only_ldap
  end

  private

  def controller_permission
    'authenticators'
  end
end
