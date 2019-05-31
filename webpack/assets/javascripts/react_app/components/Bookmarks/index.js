import { connect } from 'react-redux';
import * as BookmarksActions from './BookmarksActions';
import Bookmarks from './Bookmarks';
import reducer from './BookmarksReducer';
import {
  selectBookmarksShowModal,
  selectBookmarksStatus,
  selectBookmarksResults,
  selectBookmarksErrors,
} from './BookmarksSelectors';

const mapStateToProps = (state, { controller }) => ({
  errors: selectBookmarksErrors(state, controller),
  bookmarks: selectBookmarksResults(state, controller),
  status: selectBookmarksStatus(state, controller),
  showModal: selectBookmarksShowModal(state),
});

export const reducers = { bookmarks: reducer };

export default connect(
  mapStateToProps,
  BookmarksActions
)(Bookmarks);
