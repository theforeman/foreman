import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as actions from './AutoCompleteActions';
import reducer from './AutoCompleteReducer';
import AutoComplete from './AutoComplete';
import {
  selectAutocompleteError,
  selectAutocompleteResults,
  selectAutocompleteSearchQuery,
  selectAutocompleteStatus,
} from './AutoCompleteSelectors';

const mapStateToProps = state => ({
  error: selectAutocompleteError(state),
  results: selectAutocompleteResults(state),
  searchQuery: selectAutocompleteSearchQuery(state),
  status: selectAutocompleteStatus(state),
});

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { autocomplete: reducer };

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(AutoComplete);
