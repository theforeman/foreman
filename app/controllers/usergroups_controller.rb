class UsergroupsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:edit, :update, :destroy]
  after_filter  :refresh_external_usergroups, :only => [:create, :update]

  def index
    @usergroups = resource_base.paginate :page => params[:page]
  end

  def new
    @usergroup = Usergroup.new
  end

  def create
    @usergroup = Usergroup.new(foreman_params)
    if @usergroup.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @usergroup.update_attributes(foreman_params)
      process_success
    else
      process_error
    end
  rescue Foreman::CyclicGraphException => e
    @usergroup.errors[:usergroups] = e.record.errors[:base].join(' ')
    process_error
  end

  def destroy
    if @usergroup.destroy
      process_success
    else
      process_error
    end
  end

  private

  def find_by_id(permission = :view_usergroups)
    Usergroup.authorized(permission).find(params[:id])
  end

  def refresh_external_usergroups
    @usergroup.external_usergroups.map(&:refresh)
  end
end
