class ResourcegroupsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    respond_to do |format|
      format.html { @locations = Location.all }
    end
  end

  def create
    @resourcegroup = Resourcegroup.new

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
