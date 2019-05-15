import { STATISTICS_DATA } from '../../consts';
import { API_OPERATIONS } from '../../API';

export const getStatisticsData = charts => dispatch => {
  charts.forEach(chart => {
    dispatch({
      type: API_OPERATIONS.GET,
      key: STATISTICS_DATA,
      url: chart.url,
      payload: chart,
    });
  });
};
