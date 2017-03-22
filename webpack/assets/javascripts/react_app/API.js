import $ from 'jquery';

export default {
  get(url) {
    $.ajaxPrefilter(function (options, originalOptions, jqXHR) {
      jqXHR.originalRequestOptions = originalOptions;
    });
    return $.getJSON(url);
  },
  markNotificationAsRead(id) {
    const data = JSON.stringify({'seen': true});

    $.ajax({
      url: `/notification_recipients/${id}`,
      contentType: 'application/json',
      type: 'put',
      dataType: 'json',
      data: data,
      error: function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
      }
    });
  }
};
