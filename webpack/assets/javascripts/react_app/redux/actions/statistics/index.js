import {
  STATISTICS_DATA_REQUEST,
  STATISTICS_DATA_SUCCESS,
  STATISTICS_DATA_FAILURE,
} from '../../consts';
import { ajaxRequestAction } from '../common/';

export const getStatisticsData = charts => dispatch =>
  Promise.all(charts.map(chart => ajaxRequestAction({
    dispatch,
    requestAction: STATISTICS_DATA_REQUEST,
    successAction: STATISTICS_DATA_SUCCESS,
    failedAction: STATISTICS_DATA_FAILURE,
    url: chart.url,
    item: chart,
  })));
