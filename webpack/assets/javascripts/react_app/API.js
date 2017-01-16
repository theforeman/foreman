import ServerActions from './actions/ServerActions';
import $ from 'jquery';

export default {
  get(url) {
    $.ajaxPrefilter(function (options, originalOptions, jqXHR) {
      jqXHR.originalRequestOptions = originalOptions;
    });
    return $.getJSON(url);
  },
  getStatisticsData(url) {
    this.get(url)
      .success(
        (rawStatistics, textStatus, jqXHR) => {
          ServerActions.receivedStatistics(rawStatistics, textStatus, jqXHR);
        })
      .error((jqXHR, textStatus, errorThrown) => {
        ServerActions.statisticsRequestError(jqXHR, textStatus, errorThrown);
      });
  },
  getHostPowerData(url) {
    this.get(url)
      .success(
        (rawHosts, textStatus, jqXHR) => {
          ServerActions.receivedHostsPowerState(rawHosts, textStatus, jqXHR);
        })
      .error((jqXHR, textStatus, errorThrown) => {
        ServerActions.hostsRequestError(jqXHR, textStatus, errorThrown);
      });
  },
  getNotifications(url) {
    $.get(url)
      .success(
        (response, textStatus, jqXHR) => {
          ServerActions.receivedNotifications(response, textStatus, jqXHR);
        })
      .error((jqXHR, textStatus, errorThrown) => {
        ServerActions.notificationsRequestError(jqXHR, textStatus, errorThrown);
      });
  },
  markNotificationAsRead(url) {
    const data = JSON.stringify({'seen': true});

    $.ajax({
      url: url,
      contentType: 'application/json',
      type: 'put',
      dataType: 'json',
      data: data,
      success: function (response, textstatus, jqXHR) {
        ServerActions.notificationMarkedAsRead(response, textstatus, jqXHR);
      },
      error: function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
      }
    });
  }
};
