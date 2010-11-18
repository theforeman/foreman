class ModelsController < ApplicationController
  def index
    @search = Model.search params[:search]
    @models = @search.paginate :page => params[:page]
  end

  def new
    @model = Model.new
  end

  def create
    @model = Model.new(params[:model])
    if @model.save
      notice "Successfully created model."
      redirect_to models_url
    else
      render :action => 'new'
    end
  end

  def edit
    @model = Model.find(params[:id])
  end

  def update
    @model = Model.find(params[:id])
    if @model.update_attributes(params[:model])
      notice "Successfully updated model."
      redirect_to models_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @model = Model.find(params[:id])
    if @model.destroy
      notice "Successfully destroyed model."
    else
      error @model.errors.full_messages.join("<br/>")
    end
    redirect_to models_url
  end
end
