import $ from 'jquery';
import _ from 'lodash';

export function initInheritedRoles() {
  $('#inherited-roles .dropdown-menu a').click(({target}) => {
    $('#roles_tab li').hide();
    $(`#roles_tab li[data-id = '${target.getAttribute('data-id')}']`).show();
    $(target).closest('.dropdown')
             .children('.btn')
             .html(`${_.escape(target.text)} <span class="caret"></span>`);
  }).first().click();
}

function getSelectValues({options = []}) {
  // need to use lodash because options is an HTMLOptionsCollection, not array
  return _.filter(options, opt => opt.selected).map(opt => [opt.value, opt.text]);
}

export function taxonomyAdded(taxonomies, type) {
  const selected = [['', ''], ...getSelectValues(taxonomies)];
  const defaults = document.getElementById(`user_default_${type}_id`);

  defaults.innerHTML = selected.map(opt =>
                                      `<option value='${opt[0]}'>${_.escape(opt[1])}</option>`)
                               .join('');
}

/* eslint-disable no-undef */
export function testMail(item, url, param = {}) {
  const button = $(item),
        spinner = $('#test_indicator');

  button.addClass('disabled');
  spinner.show();

  $.ajax({
    url: url,
    type: 'put',
    data: param,
    success: ({message}) => notify(`<p>${message}</p>`, 'success'),
    error: ({responseText}) => notify(`<p>${JSON.parse(responseText).message}</p>`, 'danger'),
    complete: () => {
      spinner.hide();
      button.removeClass('disabled');
    }
  });
}
