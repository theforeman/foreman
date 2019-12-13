import { connect } from 'react-redux';
import BookmarkForm from './BookmarkForm';
import { submitForm } from '../../../../redux/actions/common/forms';

const mapStateToProps = ({ bookmarks }) => ({
  initialValues: {
    public: true,
    query: bookmarks.currentQuery || '',
    name: '',
  },
});

const mapDispatchToProps = {
  submitForm,
};

export default connect(mapStateToProps, mapDispatchToProps)(BookmarkForm);
