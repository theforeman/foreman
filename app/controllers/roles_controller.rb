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
  before_filter :require_admin

  def index
    @search = Role.search(params[:search])
    @roles = @search.paginate(:page => params[:page], :order => "builtin ASC, name ASC")
  end

  def new
    # Prefills the form with 'default user' role permissions
    @role        = Role.new({:permissions => Role.default_user.permissions})
    @permissions = @role.setable_permissions
  end

  def create
    @role = Role.new(params[:role])
    @permissions = @role.setable_permissions
    if @role.save
      process_success
    else
      process_error
    end
  end

  def edit
    @role = Role.find(params[:id])
    @permissions = @role.setable_permissions
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      process_success
    else
      process_error
    end
  end

  def destroy
    @role = Role.find(params[:id])
    if @role.destroy
      process_success
    else
      process_error
    end
  end

  def report
    @roles = Role.all(:order => 'builtin, name')
    @permissions = Foreman::AccessControl.permissions.select { |p| !p.public? }
    if request.post?
      @roles.each do |role|
        role.permissions = params[:permissions][role.id.to_s]
        role.save
      end
      notice "All non public permissions successfuly updated"
      redirect_to roles_url
    end
  end
end
