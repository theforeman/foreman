import { connect } from 'react-redux';
import { compose, combineReducers, bindActionCreators } from 'redux';

import * as actions from './AuditsPageActions';

import AuditsPage from './AuditsPage';
import {
  selectAudits,
  selectAuditsCount,
  selectAuditsMessage,
  selectAuditsPerPage,
  selectAuditsSearch,
  selectAuditsSelectedPage,
  selectAuditsHasData,
  selectAuditsHasError,
  selectAuditsIsLoadingPage,
} from './AuditsPageSelectors';
import { callOnMount, callOnPopState } from '../../../common/HOC';
import withQueryReducer from '../../common/reducerHOC/withQueryReducer';
import withDataReducer from '../../common/reducerHOC/withDataReducer';

const mapStateToProps = state => ({
  audits: selectAudits(state),
  isLoading: selectAuditsIsLoadingPage(state),
  itemCount: selectAuditsCount(state),
  message: selectAuditsMessage(state),
  page: selectAuditsSelectedPage(state),
  perPage: selectAuditsPerPage(state),
  searchQuery: selectAuditsSearch(state),
  hasError: selectAuditsHasError(state),
  hasData: selectAuditsHasData(state),
});

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = {
  auditsPage: combineReducers({
    data: withDataReducer('AUDITS_PAGE'),
    query: withQueryReducer('AUDITS_PAGE'),
  }),
};

export default compose(
  connect(mapStateToProps, mapDispatchToProps),
  callOnMount(({ initializeAudits }) => initializeAudits()),
  callOnPopState(({ initializeAudits }) => initializeAudits())
)(AuditsPage);
