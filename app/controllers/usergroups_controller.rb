class UsergroupsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Usergroup
  include Foreman::Controller::ExternalUsergroupsErrors

  before_action :find_resource, :only => [:edit, :update, :destroy]
  before_action :get_external_usergroups_to_refresh, :only => [:update]

  def index
    @usergroups = resource_base_search_and_page(:usergroups)
  end

  def new
    @usergroup = Usergroup.new
  end

  def create
    @usergroup = Usergroup.new(usergroup_params)
    if @usergroup.save && refresh_external_usergroups
      process_success
    else
      process_error
    end
  rescue => e
    external_usergroups_error(@usergroup, e)
    process_error
  end

  def edit
  end

  def update
    if @usergroup.update(usergroup_params) &&
        refresh_external_usergroups
      process_success
    else
      process_error
    end
  rescue Foreman::CyclicGraphException => e
    @usergroup.errors[:usergroups] << e.record.errors[:base].join(' ')
    process_error
  rescue => e
    external_usergroups_error(@usergroup, e)
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
