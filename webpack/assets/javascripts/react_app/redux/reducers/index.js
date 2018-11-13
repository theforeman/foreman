import { combineReducers } from 'redux';
import { reducer as form } from 'redux-form';
import bookmarks from './bookmarks';
import statistics from './statistics';
import hosts from './hosts';
import notifications from './notifications';
import toasts from './toasts';
import { reducers as passwordStrengthReducers } from '../../components/PasswordStrength';
import { reducers as breadcrumbBarReducers } from '../../components/BreadcrumbBar';
import { reducers as searchBarReducers } from '../../components/SearchBar';
import { reducers as layoutReducers } from '../../components/Layout';
import { reducers as diffModalReducers } from '../../components/ConfigReports/DiffModal';
import factChart from './factCharts';

export function combineReducersAsync(asyncReducers) {
  return combineReducers({
    bookmarks,
    form,
    statistics,
    hosts,
    notifications,
    toasts,
    ...passwordStrengthReducers,
    ...breadcrumbBarReducers,
    ...layoutReducers,
    ...asyncReducers,
    ...searchBarReducers,
    ...diffModalReducers,
    factChart,
  });
}

export default combineReducersAsync();
