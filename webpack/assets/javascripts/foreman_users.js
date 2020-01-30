/* eslint-disable jquery/no-toggle */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-hide */
/* eslint-disable jquery/no-show */
/* eslint-disable jquery/no-html */
/* eslint-disable jquery/no-closest */

import $ from 'jquery';
import { escape } from 'lodash';

export function initInheritedRoles() {
  $('#inherited-roles .dropdown-menu a')
    .click(({ target }) => {
      $('#roles_tab li').hide();
      $(`#roles_tab li[data-id = '${target.getAttribute('data-id')}']`).show();
      $(target)
        .closest('.dropdown')
        .children('.btn')
        .html(`${escape(target.text)} <span class="caret"></span>`);
    })
    .first()
    .click();
}

function getSelectValues({ options = [] }) {
  return Object.values(options)
    .filter(opt => opt.selected)
    .map(opt => [opt.value, opt.text]);
}

export function taxonomyAdded(taxonomies, type) {
  const selected = [['', ''], ...getSelectValues(taxonomies)];
  const defaults = document.getElementById(`user_default_${type}_id`);

  defaults.innerHTML = selected
    .map(opt => `<option value='${opt[0]}'>${escape(opt[1])}</option>`)
    .join('');
}

export function authSourceSelected(param) {
  const id = param.selectedOptions[0].textContent;
  $('#password').toggle(id === 'INTERNAL');
}
