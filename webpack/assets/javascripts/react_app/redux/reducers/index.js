import { combineReducers } from 'redux';
import statistics from './statistics';
import hosts from './hosts';

export default combineReducers({
    statistics,
    hosts
});
