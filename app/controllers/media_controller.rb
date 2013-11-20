class MediaController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_medium, :only => %w{edit update destroy}

  def index
    @media = Medium.authorized(:view_media).includes(:operatingsystems).search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    @authorizer = Authorizer.new(User.current, @media)
  end

  def new
    @medium = Medium.new
  end

  def create
    @medium = Medium.new(params[:medium])
    if @medium.save
      process_success
    else
      process_error
    end
  end

  def edit
    @medium = find_medium(:edit_media)
  end

  def update
    @medium = find_medium(:edit_media)
    if @medium.update_attributes(params[:medium])
      process_success
    else
      process_error
    end
  end

  def destroy
    @medium = find_medium(:destroy_media)
    if @medium.destroy
      process_success
    else
      process_error
    end
  end

  private

  def find_medium(permission = :view_media)
    Medium.authorized(permission).find(params[:id])
  end

end
