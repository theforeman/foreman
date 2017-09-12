class AuthSourceInternalController < ApplicationController

  before_action :find_resource, :only => :show

  def index
    @auth_source_internal = resource_base_search_and_page.all
  end

  private

  def controller_permission
    'authenticators'
  end
end