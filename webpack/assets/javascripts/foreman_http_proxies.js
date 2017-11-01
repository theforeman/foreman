import $ from 'jquery';
import { notify, clear } from './foreman_toast_notifications';

export function testConnection(item, url) {
  let data = $('form').serialize();

  $('#test_connection_indicator').show();
  $(item).addClass('disabled');
  clear();
  $.ajax({
    url: url,
    type: 'put',
    data: data,
    success: function(result, textstatus, xhr) {
      notify({ message: result.message, type: 'success' });
    },
    error: function(xhr) {
      let error = $.parseJSON(xhr.responseText).message;

      notify({ message: error, type: 'danger' });
    },
    complete: function(result) {
      $('#test_connection_indicator').hide();
      $(item).removeClass('disabled');
    },
  });
}
