require_dependency "audit"
class AuditsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  def index
    @audits = Audit.search_for(params[:search], :order => params[:order]).paginate :page => params[:page]
    flash.clear
  rescue => e
    error e.to_s
    @audits = Audit.search_for('', :order => params[:order]).paginate :page => params[:page]
  end

  def show
    @audit = Audit.find(params[:id])
  end
end
