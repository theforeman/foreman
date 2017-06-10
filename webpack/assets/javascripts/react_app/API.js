import $ from 'jquery';

const API = {
  getcsrfToken() {
    const token = document.querySelector('meta[name="csrf-token"]');

    if (token) {
      return token.content;
    }
    // fail gracefully when no token is found
    return '';
  },
  get(url) {
    $.ajaxPrefilter(function (options, originalOptions, jqXHR) {
      jqXHR.originalRequestOptions = originalOptions;
    });
    return $.getJSON(url);
  },
  delete(url) {
    return fetch(url, {
      credentials: 'include',
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        'X-CSRF-Token': API.getcsrfToken()
      }
    }).then(result => {
      if (result.status > 299) {
        throw result;
      }
      return result;
    });
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
        /* eslint-disable no-console */
        console.log(jqXHR);
      }
    });
  },
  markGroupNotificationAsRead(group) {
    $.ajax({
      url: `/notification_recipients/group/${group}`,
      contentType: 'application/json',
      type: 'PUT',
      error: function (jqXHR, textStatus, errorThrown) {
        /* eslint-disable no-console */
        console.log(jqXHR);
      }
    });
  }
};

export default API;
