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

const mapStateToProps = (state, { id }) => ({
  error: selectAutocompleteError(state, id),
  results: selectAutocompleteResults(state, id),
  searchQuery: selectAutocompleteSearchQuery(state, id),
  status: selectAutocompleteStatus(state, id),
});

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { autocomplete: reducer };

export default connect(mapStateToProps, mapDispatchToProps)(AutoComplete);
