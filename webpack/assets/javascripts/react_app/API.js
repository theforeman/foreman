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
  }
};
