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
