class UsergroupsController < ApplicationController
  def index
    @usergroups = Usergroup.all(:order => "name")
  end

  def new
    @usergroup = Usergroup.new
  end

  def create
    @usergroup = Usergroup.new(params[:usergroup])
    if @usergroup.save
      notice "Successfully created usergroup."
      redirect_to usergroups_path
    else
      render :action => 'new'
    end
  end

  def edit
    @usergroup = Usergroup.find(params[:id])
  end

  def update
    @usergroup = Usergroup.find(params[:id])

    if @usergroup.update_attributes(params[:usergroup])
      notice "Successfully updated usergroup."
      redirect_to usergroups_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @usergroup = Usergroup.find(params[:id])
    if @usergroup.destroy
      notice "Successfully destroyed usergroup."
    else
      logger.error @usergroup.errors.full_messages
      error @usergroup.errors.full_messages.join "<br/>"
    end
    redirect_to usergroups_path
  end
end
