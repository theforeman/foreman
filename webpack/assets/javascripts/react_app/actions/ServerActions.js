import AppDispatcher from '../dispatcher';
import {ACTIONS} from '../constants';

export default {
  receivedStatistics(rawStatistics, textStatus, jqXHR) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.RECEIVED_STATISTICS,
      rawStatistics
    });
  },

  statisticsRequestError(jqXHR, textStatus, errorThrown) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.STATISTICS_REQUEST_ERROR, info: {
        jqXHR: jqXHR,
        textStatus: textStatus,
        errorThrown: errorThrown
      }
    });
  }
};
