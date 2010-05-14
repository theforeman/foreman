class HostgroupsController < ApplicationController
  def index
    @search     = Hostgroup.search params[:search]
    @hostgroups = @search.paginate :page => params[:page]
  end

  def new
    @hostgroup = Hostgroup.new
  end

  def create
    @hostgroup = Hostgroup.new(params[:hostgroup])
    if @hostgroup.save
      flash[:foreman_notice] = "Successfully created hostgroup."
      redirect_to hostgroups_url
    else
      render :action => 'new'
    end
  end

  def edit
    @hostgroup = Hostgroup.find(params[:id])
  end

  def update
    @hostgroup = Hostgroup.find(params[:id])
    if @hostgroup.update_attributes(params[:hostgroup])
      flash[:foreman_notice] = "Successfully updated hostgroup."
      redirect_to hostgroups_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @hostgroup = Hostgroup.find(params[:id])
    if @hostgroup.destroy
      flash[:foreman_notice] = "Successfully destroyed hostgroup."
    else
      flash[:foreman_error] = @template.truncate @hostgroup.errors.full_messages.join("<br>"), 80
    end
    redirect_to hostgroups_url
  end
end
