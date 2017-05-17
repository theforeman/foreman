import $ from 'jquery';

export function showSpinner() {
  $('#turbolinks-progress').show();
}

export function hideSpinner() {
  $('#turbolinks-progress').hide();
}

export function iconText(name, innerText, iconClass) {
  let icon = `<span class="${iconClass} ${iconClass}-${name}"/>`;

  if (innerText !== '') {
    icon += `<strong>${innerText}</strong>`;
  }
  return icon;
}

export function activateDatatables() {
  $('[data-table=inline]').not('.dataTable').DataTable({
      dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'i><'col-md-6'p>>"
  });

  $('[data-table=server]').not('.dataTable').each((i, el) => {
    const url = el.getAttribute('data-source');

    $(el).DataTable({
      processing: true,
      serverSide: true,
      ordering: false,
      ajax: url,
      dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'><'col-md-6'p>>"
    });
  });
}

export function activateTooltips(el = 'body') {
  el = $(el);
  el.find('[rel="twipsy"]').tooltip({ container: 'body' });
  el.find('.ellipsis').tooltip({ container: 'body', title: function () {
                                   return (this.scrollWidth > this.clientWidth ?
                                           this.textContent : null);
                                   }
                              });
  el.find('*[title]').not('*[rel]').tooltip({ container: 'body' });
  $(document).on('page:restore', () => {$('.tooltip.in').remove();});
}

/* eslint-disable no-console, max-len */
export function deprecate(oldMethod, newMethod, version = '1.17') {
  console.warn(`DEPRECATION WARNING: you are using deprecated ${oldMethod}, it will be removed in Foreman ${version}. Use ${newMethod} instead.`);
}

export function initTypeAheadSelect(input) {
  input.select2({
    ajax: {
      url: input.data('url'),
      dataType: 'json',
      quietMillis: 250,
      data: (term, page) => ({
        q: term,
        scope: input.data('scope')
      }),
      results: (data) => ({results: data.map(({id, name}) => ({id, text: name}))}),
      cache: true
    },
    initSelection: function (element, callback) {
      $.ajax(input.data('url'), {
        data: {
          scope: input.data('scope')
        },
        dataType: 'json'
      }).done((data) => {
        if (data.length > 0) {
          callback({id: data[0].id, text: data[0].name});
        }
      });
    },
    width: '400px'
  });
}
