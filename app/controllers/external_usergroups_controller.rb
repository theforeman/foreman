class ExternalUsergroupsController < ApplicationController
  before_filter :find_by_name, :only => [:refresh]

  def refresh
    if @external_usergroup.refresh
      notice _("External user group %{name} refreshed") % { :name => @external_usergroup.name }
    else
      warning _("External user group %{name} could not be refreshed") % { :name => @external_usergroup.name }
    end
    redirect_to :usergroups
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
