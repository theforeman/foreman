import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import SearchBar from './SearchBar';
import { selectAutocompleteSearchQuery } from '../AutoComplete/AutoCompleteSelectors';
import { setAutocompleteSearchQuery } from '../AutoComplete/AutoCompleteActions';

const mapStateToProps = (
  state,
  {
    data: {
      autocomplete: { id },
    },
  }
) => ({
  searchQuery: selectAutocompleteSearchQuery(state, id),
});

const mapDispatchToProps = dispatch =>
  bindActionCreators({ setAutocompleteSearchQuery }, dispatch);

export default connect(mapStateToProps, mapDispatchToProps)(SearchBar);
