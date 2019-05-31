import { connect } from 'react-redux';

import BookmarkForm from './BookmarkForm';
import { submitForm } from '../../../../redux/actions/common/forms';

export default connect(
  ({ bookmarks }) => ({
    initialValues: {
      public: true,
      query: bookmarks.currentQuery || '',
      name: '',
    },
  }),
  { submitForm }
)(BookmarkForm);
