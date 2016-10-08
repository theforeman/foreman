import $ from 'jquery';

export function showSpinner() {
  $('#turbolinks-progress').show();
}

export function hideSpinner() {
  $('#turbolinks-progress').hide();
}

export function iconText(name, innerText, iconClass) {
  let icon = '<span class="' + iconClass + ' ' + iconClass + '-' + name + '"/>';

  if (innerText !== '') {
    icon += '<strong>' + innerText + '</strong>';
  }
  return icon;
}

export function activateDatatables() {
  $('[data-table=inline]').not('.dataTable').DataTable({
      dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'i><'col-md-6'p>>"
  });

  $('[data-table=server]').not('.dataTable').each(function () {
    const $this = $(this);
    const url = $this.data('source');

    $this.DataTable({
      processing: true,
      serverSide: true,
      ordering: false,
      ajax: url,
      dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'><'col-md-6'p>>"
    });
  });
}

export function activateSelect2(container = ':root') {
  $(container).find('select:not(.without_select2)')
    .not('.form_template select')
    .not('#interfaceForms select')
    .each((i, el) => {
      let opts = {};

      // Only allow clearing if there is a blank option with empty value
      if ($(el).find('option[value=""]:empty').length) {
        opts.allowClear = true;
        opts.placeholder = '';
      }

      $(el).select2(opts);
    });
}
