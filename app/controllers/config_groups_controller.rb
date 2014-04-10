class ConfigGroupsController < ApplicationController

  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_config_group, :only => %w{edit update destroy}

  def index
    @config_groups = ConfigGroup.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @config_group = ConfigGroup.new
  end

  def edit
  end

  def create
    @config_group = ConfigGroup.new(params[:config_group])
    if @config_group.save
      process_success :success_redirect => config_groups_path
    else
      process_error
    end
  end

  def update
    if @config_group.update_attributes(params[:config_group])
      process_success :success_redirect => config_groups_path
    else
      process_error
    end
  end

  def destroy
    if @config_group.destroy
      process_success
    else
      process_error
    end
  end

  private

  def find_config_group
    @config_group = ConfigGroup.find(params[:id])
  end

end
