import { connect } from 'react-redux';
import BookmarkForm from './BookmarkForm';
import { submitForm } from '../../../../redux/actions/common/forms';
import { selectAutocompleteSearchQuery } from '../../../AutoComplete/AutoCompleteSelectors';

const mapStateToProps = (state, { controller }) => ({
  initialValues: {
    public: true,
    query: selectAutocompleteSearchQuery(state, 'searchBar', { controller }),
  },
});

const mapDispatchToProps = {
  submitForm,
};

export default connect(mapStateToProps, mapDispatchToProps)(BookmarkForm);
