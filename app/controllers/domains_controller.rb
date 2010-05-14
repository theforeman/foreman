class DomainsController < ApplicationController
  def index
    @search  = Domain.search params[:search]
    @domains = @search.paginate :page => params[:page], :include => 'hosts'
  end

  def new
    @domain = Domain.new
  end

  def create
    @domain = Domain.new(params[:domain])
    if @domain.save
      flash[:foreman_notice] = "Successfully created domain."
      redirect_to domains_url
    else
      render :action => 'new'
    end
  end

  def edit
    @domain = Domain.find(params[:id])
  end

  def update
    @domain = Domain.find(params[:id])
    if @domain.update_attributes(params[:domain])
      flash[:foreman_notice] = "Successfully updated domain."
      redirect_to domains_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @domain = Domain.find(params[:id])
    if @domain.destroy
      flash[:foreman_notice] = "Successfully destroyed domain."
    else
      flash[:foreman_error] = @domain.errors.full_messages.join("<br>")
    end
    redirect_to domains_url
  end
end
