import { connect } from 'react-redux';
import BookmarkForm from './BookmarkForm';
import { submitForm } from '../../../../redux/actions/common/forms';
import { selectAutocompleteSearchQuery } from '../../../AutoComplete/AutoCompleteSelectors';

const mapStateToProps = (state, ownProps) => ({
  initialValues: {
    public: true,
    query:
      selectAutocompleteSearchQuery(
        { autocomplete: { id: 'searchBar' }, ...state },
        'searchBar',
        ownProps
      ) || '',
    name: '',
  },
});

const mapDispatchToProps = {
  submitForm,
};

export default connect(mapStateToProps, mapDispatchToProps)(BookmarkForm);
