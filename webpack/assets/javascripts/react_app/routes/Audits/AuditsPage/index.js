import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import { withRouter } from 'react-router-dom';

import * as actions from './AuditsPageActions';
import reducer from './AuditsPageReducer';
import AuditsPage from './AuditsPage';
import {
  selectAuditsPerPage,
  selectAuditsSelectedPage,
  selectAuditsIsLoading,
  selectAudits,
  selectAuditsCount,
  selectAuditsShowMessage,
  selectAuditsMessage,
  selectAuditsSearch,
  selectAuditsIsFetchingNext,
  selectAuditsIsFetchingPrev,
} from './AuditsPageSelector';

const mapStateToProps = state => ({
  audits: selectAudits(state),
  page: selectAuditsSelectedPage(state),
  perPage: selectAuditsPerPage(state),
  itemCount: selectAuditsCount(state),
  isLoading: selectAuditsIsLoading(state),
  showMessage: selectAuditsShowMessage(state),
  message: selectAuditsMessage(state),
  searchQuery: selectAuditsSearch(state),
  isFetchingNext: selectAuditsIsFetchingNext(state),
  isFetchingPrev: selectAuditsIsFetchingPrev(state),
});

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { auditsPage: reducer };

export default withRouter(
  connect(
    mapStateToProps,
    mapDispatchToProps
  )(AuditsPage)
);
