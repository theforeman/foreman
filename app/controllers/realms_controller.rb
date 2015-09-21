class RealmsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    @realms = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @realm = Realm.new
  end

  def create
    @realm = Realm.new(foreman_params)
    if @realm.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @realm.update_attributes(foreman_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @realm.destroy
      process_success
    else
      process_error
    end
  end
end
