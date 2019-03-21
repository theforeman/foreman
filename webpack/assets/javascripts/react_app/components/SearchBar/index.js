import { connect } from 'react-redux';
import SearchBar from './SearchBar';
import { selectAutocompleteSearchQuery } from '../AutoComplete/AutoCompleteSelectors';

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

export default connect(mapStateToProps)(SearchBar);
