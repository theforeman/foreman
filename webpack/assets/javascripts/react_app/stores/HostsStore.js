import AppDispatcher from '../dispatcher';
import {ACTIONS} from '../constants';
import AppEventEmitter from './AppEventEmitter';

// Internal object of Hosts
const _hosts = {};

class HostsEventEmitter extends AppEventEmitter {
  constructor() {
    super();
  }

  getHostsData(id) {
    _hosts[id] = _hosts[id] || { data: [] };

    return _hosts[id];
  }

  // workaround for max listeners
  maxListers(selector = 'meta[name=pagination-per-page]') {
    const element = document.querySelector(selector);

    if (element && element.content) {
      // * 2 as we have both success and failure listeners
      return (element.content * 2);
    }

    return 40;
  }
}

const HostsStore = new HostsEventEmitter();

HostsStore.setMaxListeners(HostsStore.maxListers());

AppDispatcher.register(action => {
  switch (action.actionType) {
    case ACTIONS.RECEIVED_HOSTS_POWER_STATE: {
      const { id, state, statusText, title } = action.response;

      _hosts[id] = _hosts[id] || {};
      _hosts[id].power = {
        state: state,
        title: title,
        lastChecked: Date.now(),
        statusText: statusText
      };
      HostsStore.emitChange({id: id});
      break;
    }
    case ACTIONS.HOSTS_REQUEST_ERROR: {
      HostsStore.emitError(action.info);
      break;
    }

    default:
      // no op
      break;
  }
});

export default HostsStore;
