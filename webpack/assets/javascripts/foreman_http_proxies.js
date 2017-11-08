import $ from 'jquery';
import { notify, clear } from './foreman_toast_notifications';

export function testConnection(item, url) {
  const data = $('form').serialize();

  $('#test_connection_indicator').show();
  $(item).addClass('disabled');
  clear();
  $.ajax({
    url,
    type: 'put',
    data,
    success(result, textstatus, xhr) {
      notify({ message: result.message, type: 'success' });
    },
    error(xhr) {
      const error = $.parseJSON(xhr.responseText).message;

      notify({ message: error, type: 'danger' });
    },
    complete(result) {
      $('#test_connection_indicator').hide();
      $(item).removeClass('disabled');
    },
  });
}
