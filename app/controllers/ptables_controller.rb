class PtablesController < ApplicationController
  def index
    @search  = Ptable.search params[:search]
    @ptables = @search.paginate(:page => params[:page], :include => [:operatingsystems])
  end

  def show
    @ptable = Ptable.find(params[:id])
  end

  def new
    @ptable = Ptable.new
  end

  def create
    @ptable = Ptable.new(params[:ptable])
    if @ptable.save
      flash[:foreman_notice] = "Successfully created partition table."
      redirect_to @ptable
    else
      render :action => 'new'
    end
  end

  def edit
    @ptable = Ptable.find(params[:id])
  end

  def update
    @ptable = Ptable.find(params[:id])
    if @ptable.update_attributes(params[:ptable])
      flash[:foreman_notice] = "Successfully updated partition table."
      redirect_to @ptable
    else
      render :action => 'edit'
    end
  end

  def destroy
    @ptable = Ptable.find(params[:id])
    @ptable.destroy
    flash[:foreman_notice] = "Successfully destroyed partition table."
    redirect_to ptables_url
  end
end
