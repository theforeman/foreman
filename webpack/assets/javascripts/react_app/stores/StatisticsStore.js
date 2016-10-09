import AppDispatcher from '../dispatcher';
import {ACTIONS} from '../constants';
import AppEventEmitter from './AppEventEmitter';

const _statistics = {};

class StatisticsEventEmitter extends AppEventEmitter {
  constructor() {
    super();
  }

  getStatisticsData(id) {
    _statistics[id] = _statistics[id] || { data: [] };

    return _statistics[id];
  }
}

const StatisticsStore = new StatisticsEventEmitter();

AppDispatcher.register(action => {
  switch (action.actionType) {
    case ACTIONS.RECEIVED_STATISTICS: {
      const item = action.rawStatistics;

      _statistics[item.id] = _statistics[item.id] || {};
      _statistics[item.id].data = item.data || [];
      _statistics[item.id].isLoaded = true;

      StatisticsStore.emitChange({id: item.id});
      break;
    }
    case ACTIONS.STATISTICS_REQUEST_ERROR: {
      StatisticsStore.emitError(action.info);
      break;
    }

    default:
      // no op
      break;
  }
});

export default StatisticsStore;
