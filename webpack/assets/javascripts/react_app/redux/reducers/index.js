import { combineReducers } from 'redux';
import { reducer as form } from 'redux-form';
import bookmarks from './bookmarks';
import statistics from './statistics';
import hosts from './hosts';
import notifications from './notifications';
import toasts from './toasts';
import { reducers as appReducers } from '../../ReactApp';
import { reducers as passwordStrengthReducers } from '../../components/PasswordStrength';
import { reducers as breadcrumbBarReducers } from '../../components/BreadcrumbBar';
import { reducers as autoCompleteReducers } from '../../components/AutoComplete';
import { reducers as layoutReducers } from '../../components/Layout';
import { reducers as diffModalReducers } from '../../components/ConfigReports/DiffModal';
import { reducers as editorReducers } from '../../components/Editor';
import { reducers as modelsReducers } from '../../components/ModelsTable';
import { reducers as templateGenerationReducers } from '../../components/TemplateGenerator';
import { reducers as factChartReducers } from '../../components/FactCharts';
import { reducers as statisticsPageReducers } from '../../routes/Statistics/StatisticsPage';
import { reducers as fillReducers } from '../../components/common/Fill';

export function combineReducersAsync(asyncReducers) {
  return combineReducers({
    bookmarks,
    form,
    statistics,
    hosts,
    notifications,
    toasts,
    ...appReducers,
    ...passwordStrengthReducers,
    ...breadcrumbBarReducers,
    ...layoutReducers,
    ...asyncReducers,
    ...autoCompleteReducers,
    ...diffModalReducers,
    ...editorReducers,
    ...modelsReducers,
    ...templateGenerationReducers,
    ...factChartReducers,
    ...statisticsPageReducers,
    ...fillReducers,
  });
}

export default combineReducersAsync();
