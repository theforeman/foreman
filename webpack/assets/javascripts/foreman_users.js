import $ from 'jquery';
import { escape } from 'lodash';
import { notify } from './foreman_toast_notifications';

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

/* eslint-disable no-undef */
export function testMail(item, url, param = {}) {
  const button = $(item);
  const spinner = $('#test_indicator');

  button.addClass('disabled');
  spinner.show();

  $.ajax({
    url,
    type: 'put',
    data: param,
    success: ({ message }) => notify({ message: `<p>${message}</p>`, type: 'success' }),
    error: ({ responseText }) =>
      notify({
        message: `<p>${JSON.parse(responseText).message}</p>`,
        type: 'danger',
      }),
    complete: () => {
      spinner.hide();
      button.removeClass('disabled');
    },
  });
}
