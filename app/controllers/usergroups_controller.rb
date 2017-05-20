class UsergroupsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Usergroup

  before_action :find_resource, :only => [:edit, :update, :destroy]
  before_action :get_external_usergroups_to_refresh, :only => [:update]
  after_action  :refresh_external_usergroups, :only => [:create, :update]

  def index
    @usergroups = resource_base_search_and_page(:usergroups)
  end

  def new
    @usergroup = Usergroup.new
  end

  def create
    @usergroup = Usergroup.new(usergroup_params)
    if @usergroup.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @usergroup.update_attributes(usergroup_params)
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

  def get_external_usergroups_to_refresh
    # we need to load current status, so we call all explicitly
    @external_usergroups = @usergroup.external_usergroups.to_a
  end

  def external_usergroups
    @external_usergroups || []
  end

  def refresh_external_usergroups
    (external_usergroups + @usergroup.external_usergroups).uniq.map(&:refresh)
  end
end
