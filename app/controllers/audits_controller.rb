require 'audit_extensions'

class AuditsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :setup_search_options, :only => :index

  def index
    Audit.unscoped { @audits = Audit.search_for(params[:search], :order => params[:order]).paginate :page => params[:page] }
  rescue => e
    error e.to_s
    @audits = Audit.search_for('', :order => params[:order]).paginate :page => params[:page]
  end

  def show
    @audit = Audit.find(params[:id])
    @history = Audit.descending.where(:auditable_id => @audit.auditable_id, :auditable_type => @audit.auditable_type)
  end
end
