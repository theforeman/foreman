import ServerActions from './actions/ServerActions';

export default {
  getStatisticsData(url) {
    $.ajaxPrefilter(function (options, originalOptions, jqXHR) {
      jqXHR.originalRequestOptions = originalOptions;
    });
    $.getJSON(url)
      .success(
        (rawStatistics, textStatus, jqXHR) => {
          ServerActions.receivedStatistics(rawStatistics, textStatus, jqXHR);
        })
      .error((jqXHR, textStatus, errorThrown) => {
        ServerActions.statisticsRequestError(jqXHR, textStatus, errorThrown);
      });
  }
};
