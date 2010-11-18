class DomainsController < ApplicationController
  before_filter :find_by_name, :only => %w{show edit update destroy}

  def index
    respond_to do |format|
      format.html do
        @search  = Domain.search params[:search]
        @domains = @search.paginate :page => params[:page], :include => 'hosts'
      end
      format.json { render :json => Domain.all }
    end
  end

  def new
    @domain = Domain.new
  end

  def show
    respond_to do |format|
      format.json { render :json => @domain }
    end
  end

  def create
    @domain = Domain.new(params[:domain])
    if @domain.save
      notice "Successfully created domain."
      redirect_to domains_url
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @domain.update_attributes(params[:domain])
      notice "Successfully updated domain."
      redirect_to domains_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @domain.destroy
      notice "Successfully destroyed domain."
    else
      error @domain.errors.full_messages.join("<br/>")
    end
    redirect_to domains_url
  end

end
