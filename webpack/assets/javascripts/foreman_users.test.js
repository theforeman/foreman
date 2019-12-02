/* eslint-disable jquery/no-filter */
/* eslint-disable jquery/no-sizzle */
/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-text */
/* eslint-disable jquery/no-css */

import $ from 'jquery';
import * as users from './foreman_users';

jest.unmock('jquery');
jest.unmock('./foreman_users');

describe('initInheritedRoles', () => {
  it('updates the button text and role list on click', () => {
    document.body.innerHTML = `<div id="inherited-roles">
        <div class="dropdown">
          <button class="btn btn-default dropdown-toggle" type="button"
                  id="usergroupsDropdownMenuBtn" data-toggle="dropdown">
            Second <span class="caret"></span>
          </button>
          <ul class="dropdown-menu" role="menu"
              aria-labelledby="usergroupsDropdownMenuBtn">
            <li role="presentation">
              <a role="menuitem" tabindex="-1"
                 data-id='2'">Second</a>
            </li>
            <li role="presentation">
              <a role="menuitem" tabindex="-1"
                 data-id='1'">First</a>
            </li>
          </ul>
        </div>
        <ul class="list-group" id="roles_tab">
          <li data-id="2" class="list-group-item">
            Manager
          </li>
          <li data-id="1" class="list-group-item hidden" style="display: none;">
            Viewer
          </li>
        </ul>
      </div>`;

    users.initInheritedRoles();
    $('.dropdown-menu li a')
      .last()
      .click();
    expect($('.btn').text()).toContain('First');
    expect($('.list-group li[data-id="1"]').css('display')).not.toEqual('none');
    expect($('.list-group li[data-id="2"]').css('display')).toEqual('none');
  });
});

describe('taxonomyAdded', () => {
  window.users = users; // so the callback knows about it
  it('updates the default organization selection according to selected taxonomies', () => {
    document.body.innerHTML = `<select multiple id='user_organization_ids'
             onchange='users.taxonomyAdded(this, "organization")'>
       <option value="1">aaa</option>
       <option value="2">bbb</option>
     </select>
     <select id="user_default_organization_id">
       <option value=""></option>
     </select>`;

    expect($('#user_default_organization_id option')).toHaveLength(1);
    $('#user_organization_ids')
      .val('2')
      .change();
    expect($('#user_default_organization_id option')).toHaveLength(2);
    $('#user_organization_ids')
      .val([2, 1])
      .change();
    expect($('#user_default_organization_id option')).toHaveLength(3);
    $('#user_organization_ids')
      .val('')
      .change();
    expect($('#user_default_organization_id option')).toHaveLength(1);
  });
});

describe('users Password', () => {
  // the following test is disabled. I wasn't able to simulate a change event on a select2 dropdown
  // eslint-disable-next-line jest/no-disabled-tests
  xit('should toggle password field', () => {
    document.body.innerHTML = `
    <div>
      <select onchange="users.authSourceSelected(this)" name="user[auth_source_id]"
        id="user_auth_source_id">
        <option value=""></option>
        <option value="8">LDAP-QA</option>
        <option value="9">INTERNAL</option>
        <option value="10">LDAP-CORP</option>
      </select>
      <div id="password" style="display:none;">
        <input type="password" name="user[password]" id="user_password" class="ReactPasswordStrength-input form-control" value="">
        <input id="password_confirmation" name="user[password_confirmation]" type="password" class="form-control">
      </div>
    </div>`;

    $('#user_auth_source_id')
      .val('9')
      .change();
    expect($('#password input').filter(':visible')).toHaveLength(2);
    $('#user_auth_source_id')
      .val('')
      .change();
    expect($('#password input').filter(':visible')).toHaveLength(0);
  });
});
