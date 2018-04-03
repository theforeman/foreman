import { combineReducers } from 'redux';
import { reducer as reduxFormReducer } from 'redux-form';
import bookmarks from './bookmarks';
import statistics from './statistics';
import hosts from './hosts';
import notifications from './notifications/';
import toasts from './toasts';
import passwordStrength from './user/passwordStrength';
import { reducers as breadcrumbBarReducers } from '../../components/BreadcrumbBar';

export function combineReducersAsync(asyncReducers) {
  return combineReducers({
    bookmarks,
    form: reduxFormReducer,
    statistics,
    hosts,
    notifications,
    toasts,
    passwordStrength,
    ...breadcrumbBarReducers,
    ...asyncReducers,
  });
}

export default combineReducersAsync();
