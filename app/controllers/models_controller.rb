class ModelsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    values = Model.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html do
        @models  = values.paginate :page => params[:page]
        @counter = Host.group(:model_id).where(:model_id => @models.pluck(:id)).count
      end
      format.json { render :json => values }
    end
  end

  def new
    @model = Model.new
  end

  def create
    @model = Model.new(params[:model])
    if @model.save
      process_success
    else
      process_error
    end
  end

  def edit
    @model = Model.find(params[:id])
  end

  def update
    @model = Model.find(params[:id])
    if @model.update_attributes(params[:model])
      process_success
    else
      process_error
    end
  end

  def destroy
    @model = Model.find(params[:id])
    if @model.destroy
      process_success
    else
      process_error
    end
  end
end
