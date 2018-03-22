class ExternalUsergroupsController < ApplicationController
  include Foreman::Controller::ExternalUsergroupsErrors

  before_action :find_resource, :only => [:refresh]

  def refresh
    if @external_usergroup.refresh
      success _("External user group %{name} refreshed") % { :name => @external_usergroup.name }
      redirect_to usergroups_path
    else
      message = _("External user group %{name} could not be refreshed.") % { :name => @external_usergroup.name }
      message += ' ' + @external_usergroup.errors.full_messages.join('. ') if @external_usergroup.errors.present?
      warning message
      process_error :redirect => edit_usergroup_url(@external_usergroup.usergroup)
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
