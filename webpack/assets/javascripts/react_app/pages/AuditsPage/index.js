import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as actions from './AuditsPageActions';
import reducer from './AuditsPageReducer';
import AuditsPage from './AuditsPage';
import { selectAutocompleteSearchQuery } from '../../components/AutoComplete/AutoCompleteSelectors';
import {
  selectAuditsPerPage,
  selectAuditsSelectedPage,
  selectAudits,
  selectAuditsCount,
  selectAuditsShowMessage,
  selectAuditsMessage,
} from './AuditsPageSelector';

const mapStateToProps = state => ({
  audits: selectAudits(state),
  page: selectAuditsSelectedPage(state),
  perPage: selectAuditsPerPage(state),
  itemCount: selectAuditsCount(state),
  showMessage: selectAuditsShowMessage(state),
  message: selectAuditsMessage(state),
  searchQuery: selectAutocompleteSearchQuery(state),
});

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { auditsPage: reducer };

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(AuditsPage);
