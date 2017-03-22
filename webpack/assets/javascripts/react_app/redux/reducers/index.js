import { combineReducers } from 'redux';
import statistics from './statistics';
import hosts from './hosts';
import notifications from './notifications/';

export default combineReducers({
    statistics,
    hosts,
    notifications
});
