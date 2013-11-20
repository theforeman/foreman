class UsergroupsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    @usergroups = Usergroup.authorized(:view_usergroups).paginate :page => params[:page]
    @authorizer = Authorizer.new(User.current, @usergroups)
  end

  def new
    @usergroup = Usergroup.new
  end

  def create
    @usergroup = Usergroup.new(params[:usergroup])
    if @usergroup.save
      process_success
    else
      process_error
    end
  end

  def edit
    @usergroup = find_by_id(:edit_usergroups)
  end

  def update
    @usergroup = find_by_id(:edit_usergroups)
    if @usergroup.update_attributes(params[:usergroup])
      process_success
    else
      process_error
    end
  rescue Foreman::CyclicGraphException => e
    @usergroup.errors[:usergroups] = e.record.errors[:base].join(' ')
    process_error
  end

  def destroy
    @usergroup = find_by_id(:destroy_usergroups)
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
end
