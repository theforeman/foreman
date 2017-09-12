class AuthSourceInternalController < ApplicationController

  before_action :find_resource, :only => :index

  def index
    @auth_source = AuthSource.except_hidden.to_a.delete_if { |a| a.to_label.nil? }
  end

  private

  def controller_permission
    'authenticators'
  end
end
