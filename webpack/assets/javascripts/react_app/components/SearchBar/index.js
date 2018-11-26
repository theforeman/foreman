import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as actions from '../AutoComplete/AutoCompleteActions';
import reducer from '../AutoComplete/AutoCompleteReducer';
import SearchBar from './SearchBar';
import {
  selectAutocompleteError,
  selectAutocompleteResults,
  selectAutocompleteSearchQuery,
  selectAutocompleteStatus,
} from '../AutoComplete/AutoCompleteSelectors';

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
)(SearchBar);
