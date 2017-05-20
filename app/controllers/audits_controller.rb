class AuditsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_action :setup_search_options, :only => :index

  def index
    Audit.unscoped { @audits = resource_base_search_and_page.includes(:user) }
  end

  def show
    @audit = resource_base.find(params[:id])
    @history = resource_base.includes(:user).descending.where(:auditable_id => @audit.auditable_id, :auditable_type => @audit.auditable_type)
  end

  private

  def controller_permission
    'audit_logs'
  end
end
