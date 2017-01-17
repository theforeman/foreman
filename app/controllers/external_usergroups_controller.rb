class ExternalUsergroupsController < ApplicationController
  include Foreman::Controller::ExternalUsergroupsErrors

  before_action :find_resource, :only => [:refresh]

  def refresh
    if @external_usergroup.refresh
      notice _("External user group %{name} refreshed") % { :name => @external_usergroup.name }
    else
      warning _("External user group %{name} could not be refreshed") % { :name => @external_usergroup.name }
    end
  rescue => e
    external_usergroups_error(@external_usergroup, e)
    process_error :redirect => edit_usergroup_url(@external_usergroup.usergroup)
  end

  private

  def action_permission
    case params[:action]
      when 'refresh'
        'edit'
      else
        super
    end
  end
end
