import Immutable from 'seamless-immutable';
import { compose, bindActionCreators, combineReducers } from 'redux';
import { connect } from 'react-redux';
import URI from 'urijs';

import SettingsPage from './SettingsPage';
import { deepPropsToCamelCase } from '../../../common/helpers';

import * as actions from './SettingsPageActions';

import { callOnMount, callOnPopState } from '../../../common/HOC';

import withDataReducer from '../../common/reducerHOC/withDataReducer';

import testEmailReducer from './components/TestEmail/TestEmailReducer';

import {
  selectSettings,
  selectGroupedSettings,
  selectIsLoading,
  selectHasError,
  selectHasData,
  selectErrorMsg,
} from './SettingsPageSelectors';

const mapStateToProps = (state, ownProps) => ({
  settings: selectSettings(state),
  pageParams: paramsFromHistory(ownProps.history),
  groupedSettings: selectGroupedSettings(state),
  isLoading: selectIsLoading(state),
  hasData: selectHasData(state),
  hasError: selectHasError(state),
  errorMsg: selectErrorMsg(state),
});

export const initialState = Immutable({
  results: [],
});

const extendReducer = (state, type, payload) => {
  switch (type) {
    case 'SETTINGS_FORM_SUBMITTED': {
      return state.set(
        'results',
        state.results.map(setting =>
          payload.data && payload.data.id === setting.id
            ? deepPropsToCamelCase(payload.data)
            : setting
        )
      );
    }
    default:
      return state;
  }
};

export const reducers = {
  settingsPage: combineReducers({
    pageContent: withDataReducer('SETTINGS_PAGE', initialState, extendReducer),
    testEmail: testEmailReducer,
  }),
};

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

const paramsFromHistory = history => {
  const baseParams = { search: '' };

  if (!history || !history.location) {
    return baseParams;
  }

  const parsedSearch = URI(history.location.search).search(true);

  return parsedSearch.search ? { search: parsedSearch.search } : baseParams;
};

const onMount = props => props.initializeSettings(props.pageParams);

export default compose(
  connect(mapStateToProps, mapDispatchToProps),
  callOnMount(onMount),
  callOnPopState(onMount)
)(SettingsPage);
