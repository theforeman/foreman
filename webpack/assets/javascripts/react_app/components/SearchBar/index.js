import { connect } from 'react-redux';
import SearchBar from './SearchBar';
import { selectAutocompleteSearchQuery } from '../AutoComplete/AutoCompleteSelectors';

const mapStateToProps = (state, props) => ({
  searchQuery: selectAutocompleteSearchQuery(state, props.autocomplete.id),
});

export default connect(mapStateToProps)(SearchBar);
