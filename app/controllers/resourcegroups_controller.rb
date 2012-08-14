class ResourcegroupsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    begin
      # TODO: Get the resource groups that belong to the current user
      resourcegroups = User.current.admin? ? Resourcegroup : Resourcegroup
      values = resourcegroups.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
    end

    respond_to do |format|
      format.html do
        @resourcegroups = values.paginate :page => params[:page]
      end
    end
  end

  def new
    @resourcegroup = Resourcegroup.new
  end

  def create
    @resourcegroup = Resourcegroup.new(params[:resourcegroup])

    if @resourcegroup.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @resourcegroup.update_attributes(params[:resourcegroup])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @resourcegroup.destroy
      process_success
    else
      process_error
    end
  end

  private
  def find_resourcegrounp
    @resourcegroup = Resourcegroup.find(params[:id])
  end
end
