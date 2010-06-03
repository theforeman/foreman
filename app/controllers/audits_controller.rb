class AuditsController < ApplicationController
  def index
    @search = Audit.search params[:search]
    @audits = @search.paginate :page => params[:page]
  end

  def show
    @audit = Audit.find(params[:id])
  end
end
