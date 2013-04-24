# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
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

require 'test_helper'

class RolesControllerTest < ActionController::TestCase

  def test_get_index
    get :index, {}, set_session_user
    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:roles)
    assert_equal Role.all.sort, [assigns(:roles)].flatten.sort

    assert_tag :tag => 'a', :attributes => { :href => '/roles/1/edit' },
      :content => 'Manager'
  end

  def test_get_new
    get :new, {}, set_session_user
    assert_response :success
    assert_template 'new'
  end

  def test_post_new_with_validaton_failure
    post :create, { :role => {:name => '',
      :permissions => ['add_hosts', 'edit_hosts', 'edit_ptables', '']
    }}, set_session_user

    assert_response :success
    assert_template 'new'
  end

  def test_get_edit
    get :edit, {:id => 1}, set_session_user
    assert_response :success
    assert_template 'edit'
    assert_equal Role.find(1), assigns(:role)
  end

  def test_post_edit
    put :update, {:id => 1,
      :role => {:name => 'Manager',
        :permissions => ['edit_hosts']
    }}, set_session_user

    assert_redirected_to roles_path
    role = Role.find(1)
    assert_equal [:edit_hosts], role.permissions
  end

  def test_destroy
    r = Role.new(:name => 'ToBeDestroyed', :permissions => [:view_ptables])
    assert r.save

    delete :destroy, {:id => r}, set_session_user
    assert_redirected_to roles_path
    assert_nil Role.find_by_id(r.id)
  end

  def test_destroy_role_in_use
    users(:one).roles = [roles(:manager)] # make user one a manager
    delete :destroy, {:id => roles(:manager)}, set_session_user
    assert_redirected_to roles_path
    assert_equal 'Role is in use', flash[:error]
    assert_not_nil Role.find_by_id(roles(:manager).id)
  end

  def test_get_report
    get :report, {}, set_session_user
    assert_response :success
    assert_template 'report'

    assert_not_nil assigns(:roles)
    assert_equal Role.all.sort, assigns(:roles).sort

  end

  def test_post_report
    post :report, { :permissions => { '0' => '', '1' => ['edit_issues'], '3' => ['add_issues', 'delete_issues']} }, set_session_user
    assert_redirected_to roles_path

    assert_equal [:edit_issues], Role.find(1).permissions
    assert_equal [:add_issues, :delete_issues], Role.find(3).permissions
    assert Role.find(2).permissions.empty?
  end

  def test_clear_all_permissions
    post :report, { :permissions => { '0' => '' } }, set_session_user
    assert_redirected_to roles_path
    assert Role.find(1).permissions.empty?
  end

end
