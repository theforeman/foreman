class PtablesController < ApplicationController
  before_filter :find_ptable, :only => %w{show edit update destroy}

  def index
    respond_to do |format|
      format.html do
        @search  = Ptable.search params[:search]
        @ptables = @search.paginate(:page => params[:page], :include => [:operatingsystems])
      end
      format.json { render :json => Ptable.all }
    end
  end

  def show
    respond_to do |format|
      format.json { render :json => @ptable }
    end
  end

  def new
    @ptable = Ptable.new
  end

  def create
    @ptable = Ptable.new(params[:ptable])
    if @ptable.save
      notice "Successfully created partition table."
      redirect_to ptables_url
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @ptable.update_attributes(params[:ptable])
      notice "Successfully updated partition table."
      redirect_to ptables_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @ptable.destroy
    notice "Successfully destroyed partition table."
    redirect_to ptables_url
  end

  private
  def find_ptable
    @ptable = Ptable.find(params[:id])
  end

end
