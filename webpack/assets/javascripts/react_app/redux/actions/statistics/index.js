import API from '../../../API';
import {
  STATISTICS_DATA_REQUEST,
  STATISTICS_DATA_SUCCESS,
  STATISTICS_DATA_FAILURE
} from '../../consts';

export const getStatisticsData = charts => dispatch => {
  dispatch({ type: STATISTICS_DATA_REQUEST, payload: charts });
  charts.forEach(chart => {
    API.get(chart.url).then(
      result => dispatch({ type: STATISTICS_DATA_SUCCESS, payload: result }),
      (jqXHR, textStatus, error) => dispatch(
        { type: STATISTICS_DATA_FAILURE, payload: { error, id: chart.id } }
      )
    );
  });
};
