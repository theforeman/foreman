class MediaController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Medium

  before_action :find_resource, :only => [:edit, :update, :destroy, :clone]

  def index
    @media = resource_base_search_and_page.includes(:operatingsystems)
  end

  def new
    @medium = Medium.new
  end

  def create
    @medium = Medium.new(medium_params)
    if @medium.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @medium.update(medium_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @medium.destroy
      process_success
    else
      process_error
    end
  end

  def clone
    @medium = @medium.dup
    render('new')
  end

  private

  def action_permission
    case params[:action]
      when 'clone'
        :create
      else
        super
    end
  end
end
