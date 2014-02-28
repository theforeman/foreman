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
  before_filter :find_by_id, :only => [:clone, :edit, :update, :destroy]

  def index
    @roles = Role.search_for(params[:search], :order => params[:order]).paginate :page => params[:page]
  end

  def new
    # Prefills the form with 'default user' role permissions
    @role = Role.new({:permissions => Role.default_user.permissions})
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      process_success
    else
      process_error
    end
  end

  def clone
    new_role = @role.dup :include => [:filters => :permissions]
    new_role.name += '_clone'
    if new_role.save
      flash[:notice] = _("Role %{new_role_name} cloned from role %{role_name}") %
          { :new_role_name => new_role.name, :role_name => @role.name }
    else
     flash[:error] = _("Role %{role_name} could not be cloned: %{errors}") %
         { :role_name => @role.name, :errors => new_role.errors.full_messages.join(', ') }
    end
    redirect_to roles_url
  end

  def edit
  end

  def update
    if @role.update_attributes(params[:role])
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

  def find_by_id
    @role = Role.find(params[:id])
  end

  def action_permission
    case params[:action]
      when 'clone'
        'view'
      else
        super
    end
  end
end
