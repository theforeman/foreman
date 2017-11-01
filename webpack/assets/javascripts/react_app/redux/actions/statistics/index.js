import { ajaxRequestAction } from '../common/';
import {
  STATISTICS_DATA_REQUEST,
  STATISTICS_DATA_SUCCESS,
  STATISTICS_DATA_FAILURE,
} from '../../consts';
export const getStatisticsData = charts => dispatch => {
  charts.forEach(chart => {
    ajaxRequestAction({
      dispatch,
      requestAction: STATISTICS_DATA_REQUEST,
      successAction: STATISTICS_DATA_SUCCESS,
      failedAction: STATISTICS_DATA_FAILURE,
      url: chart.url,
      item: chart,
    });
  });
};
