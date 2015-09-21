# redMine - project management software
# Copyright (C) 2006  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class RolesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:clone, :edit, :update, :destroy]

  def index
    @roles = Role.search_for(params[:search], :order => params[:order]).paginate :page => params[:page]
  end

  def new
    # Prefills the form with 'default user' role permissions
    @role = Role.new({:permissions => Role.default_user.permissions})
  end

  def create
    @role = role_from_form

    if @role.save
      process_success
    else
      process_error
    end
  end

  def clone
    @cloned_role      = true
    @original_role_id = @role.id
    notice(_("Role cloned from role %{old_name}") % { :old_name => @role.name })
    @role = Role.new
    render :action => :new
  end

  def edit
  end

  def update
    if @role.update_attributes(foreman_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @role.destroy
      process_success
    else
      process_error
    end
  end

  private

  def action_permission
    case params[:action]
      when 'clone'
        'view'
      else
        super
    end
  end

  def role_from_form
    if params[:original_role_id].present?
      new_role = Role.find(params[:original_role_id]).
                   deep_clone(:include => [:filters => :filterings])
      new_role.name    = foreman_params[:name]
      new_role.builtin = false
    else
      new_role = Role.new(foreman_params)
    end

    new_role
  end
end
