import { connect } from 'react-redux';
import BookmarkForm from './BookmarkForm';
import { submitForm } from '../../../../redux/actions/common/forms';
import { selectAutocompleteSearchQuery } from '../../../AutoComplete/AutoCompleteSelectors';

const mapStateToProps = (state, { controller, id = 'searchBar' }) => ({
  initialValues: {
    public: true,
    query: selectAutocompleteSearchQuery(state, id, { controller }),
  },
});

const mapDispatchToProps = {
  submitForm,
};

export default connect(mapStateToProps, mapDispatchToProps)(BookmarkForm);
