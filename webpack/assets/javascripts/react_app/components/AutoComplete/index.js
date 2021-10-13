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
  selectAutocompleteIsDisabled,
  selectAutocompleteUrl,
  selectAutocompleteTrigger,
} from './AutoCompleteSelectors';

const mapStateToProps = (state, ownProps) => {
  const { id } = ownProps;
  return {
    error: selectAutocompleteError(state, id, ownProps),
    results: selectAutocompleteResults(state, id, ownProps),
    searchQuery: selectAutocompleteSearchQuery(state, id, ownProps),
    status: selectAutocompleteStatus(state, id, ownProps),
    disabled: selectAutocompleteIsDisabled(state, id, ownProps),
    url: selectAutocompleteUrl(state, id, ownProps),
    trigger: selectAutocompleteTrigger(state, id, ownProps),
  };
};

const mapDispatchToProps = (dispatch) => bindActionCreators(actions, dispatch);

export const reducers = { autocomplete: reducer };

export default connect(mapStateToProps, mapDispatchToProps)(AutoComplete);
