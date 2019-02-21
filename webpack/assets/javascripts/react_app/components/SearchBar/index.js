import { connect } from 'react-redux';
import SearchBar from './SearchBar';
import { selectAutocompleteSearchQuery } from '../AutoComplete/AutoCompleteSelectors';

const mapStateToProps = state => ({
  searchQuery: selectAutocompleteSearchQuery(state),
});

export default connect(mapStateToProps)(SearchBar);
