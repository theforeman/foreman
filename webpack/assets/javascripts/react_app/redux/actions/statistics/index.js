import { STATISTICS_DATA } from '../../consts';
import { get } from '../../API';

export const getStatisticsData = charts => dispatch => {
  charts.forEach(chart => {
    dispatch(
      get({
        key: STATISTICS_DATA,
        url: chart.url,
        payload: chart,
      })
    );
  });
};
