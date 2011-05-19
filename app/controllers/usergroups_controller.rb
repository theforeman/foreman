class UsergroupsController < ApplicationController
  def index
    @usergroups = Usergroup.paginate :page => params[:page]
    respond_to do |format|
      format.html
      format.json { render :json => @usergroups}
    end
  end

  def new
    @usergroup = Usergroup.new
  end

  def create
    @usergroup = Usergroup.new(params[:usergroup])
    if @usergroup.save
      process_success
    else
      process_error
    end
  end

  def edit
    @usergroup = Usergroup.find(params[:id])
  end

  def update
    @usergroup = Usergroup.find(params[:id])
    if @usergroup.update_attributes(params[:usergroup])
      process_success
    else
      process_error
    end
  end

  def destroy
    @usergroup = Usergroup.find(params[:id])
    if @usergroup.destroy
      process_success
    else
      process_error
    end
  end
end
