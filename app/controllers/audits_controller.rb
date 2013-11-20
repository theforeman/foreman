class AuditsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :setup_search_options, :only => :index

  def index
    Audit.unscoped { @audits = Audit.authorized(:view_audit_logs).search_for(params[:search], :order => params[:order]).paginate :page => params[:page] }
  end

  def show
    @audit = Audit.authorized(:view_audit_logs).find(params[:id])
    @history = Audit.authorized(:view_audit_logs).descending.where(:auditable_id => @audit.auditable_id, :auditable_type => @audit.auditable_type)
  end
end
