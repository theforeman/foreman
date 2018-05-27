import $ from 'jquery';
import { showSpinner, hideSpinner } from '../foreman_tools';

export function getResourcePools(item) {
  // eslint-disable-next-line camelcase
  const data = { cluster_id: $(item).val() };
  const url = $(item).data('url');

  showSpinner();
  const selectbox = $('select[id$="resource_pool"]');

  selectbox.select2('destroy').empty();
  $.ajax({
    type: 'get',
    url,
    data,
    complete() {
      hideSpinner();
    },
    success(request) {
      request.forEach(({ name }) => {
        $('<option>')
          .text(name)
          .val(name)
          .appendTo(selectbox);
      });
      $(selectbox).select2();
    },
  });
}
