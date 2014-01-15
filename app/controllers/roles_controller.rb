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

  def index
    @roles = Role.search_for(params[:search], :order => params[:order]).paginate :page => params[:page]
  end

  def new
    # Prefills the form with 'default user' role permissions
    @role        = Role.new({:permissions => Role.default_user.permissions})
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      process_success
    else
      process_error
    end
  end

  def edit
    @role = Role.find(params[:id])
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

end
