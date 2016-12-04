jest.unmock('./foreman_users');
const users = require('./foreman_users');

describe('initInheritedRoles', () => {
  it('updates the button text and role list on click', () => {
    const $ = require('jquery');

    window._ = require('lodash');
    document.body.innerHTML =
      `<div id="inherited-roles">
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
    $('.dropdown-menu li a').last().click();
    expect($('.btn').text()).toContain('First');
    expect($('.list-group li[data-id="1"]').is(':visible')).toBeTruthy();
    expect($('.list-group li[data-id="2"]').is(':visible')).toBeFalsy();
  });
});
