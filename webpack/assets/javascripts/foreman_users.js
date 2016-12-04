import $ from 'jquery';

export function initInheritedRoles() {
  $('#inherited-roles .dropdown-menu a').click(({target}) => {
    $('#roles_tab li').hide();
    $(`#roles_tab li[data-id = '${target.getAttribute('data-id')}']`).show();
    $(target).closest('.dropdown')
             .children('.btn')
             .html(`${_.escape(target.text)} <span class="caret"></span>`);
  }).first().click();
}
