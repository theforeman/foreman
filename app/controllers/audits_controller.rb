class AuditsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :setup_search_options, :only => :index

  def index
    Audit.unscoped { @audits = resource_base.search_for(params[:search], :order => params[:order]).paginate :page => params[:page] }
  end

  def show
    @audit = resource_base.find(params[:id])
    @history = resource_base.descending.where(:auditable_id => @audit.auditable_id, :auditable_type => @audit.auditable_type)
  end

  private

  def controller_permission
    'audit_logs'
  end

end
