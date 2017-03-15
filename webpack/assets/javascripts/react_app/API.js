import ServerActions from './actions/ServerActions';
import NotificationActions from './actions/NotificationActions';
import { STATUS } from './constants';
import $ from 'jquery';

export default {
  get(url) {
    $.ajaxPrefilter(function (options, originalOptions, jqXHR) {
      jqXHR.originalRequestOptions = originalOptions;
    });
    return $.getJSON(url);
  },
  getNotifications(url) {
    NotificationActions.setRequestStatus(STATUS.PENDING);
    $.get(url)
      .success(
        (response, textStatus, jqXHR) => {
          ServerActions.receivedNotifications(response, textStatus, jqXHR);
        })
      .error((jqXHR, textStatus, errorThrown) => {
        ServerActions.notificationsRequestError(jqXHR, textStatus, errorThrown);
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
        console.log(jqXHR);
      }
    });
  }
};
