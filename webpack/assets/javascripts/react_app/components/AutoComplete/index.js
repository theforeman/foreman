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
  selectAutocompleteUrl,
  selectAutocompleteIsDisabled,
  selectAutocompleteTrigger,
} from './AutoCompleteSelectors';

const mapStateToProps = (state, { id }) => ({
  id,
  error: selectAutocompleteError(state, id),
  results: selectAutocompleteResults(state, id),
  searchQuery: selectAutocompleteSearchQuery(state, id),
  status: selectAutocompleteStatus(state, id),
  url: selectAutocompleteUrl(state, id),
  isDisabled: selectAutocompleteIsDisabled(state, id),
  trigger: selectAutocompleteTrigger(state, id),
});

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { autocomplete: reducer };

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(AutoComplete);
