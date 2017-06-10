import { combineReducers } from 'redux';
import statistics from './statistics';
import hosts from './hosts';
import notifications from './notifications/';
import toasts from './toasts';
import users from './users';
import { reducer as reduxFormReducer } from 'redux-form';
export default combineReducers({
  form: reduxFormReducer,
  statistics,
  hosts,
  notifications,
  toasts,
  users
});
