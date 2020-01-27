import { connect } from 'react-redux';
import { BOOKMARKS_MODAL } from './BookmarksConstants';
import * as bookmarksActions from './BookmarksActions';
import { bindForemanModalActionsToId } from '../ForemanModal/ForemanModalActions';
import { selectIsModalOpen } from '../ForemanModal/ForemanModalSelectors';
import Bookmarks from './Bookmarks';
import reducer from './BookmarksReducer';
import {
  selectBookmarksStatus,
  selectBookmarksResults,
  selectBookmarksErrors,
} from './BookmarksSelectors';

const mapStateToProps = (state, { controller }) => ({
  errors: selectBookmarksErrors(state, controller),
  bookmarks: selectBookmarksResults(state, controller),
  status: selectBookmarksStatus(state, controller),
  isModalOpen: selectIsModalOpen(state, BOOKMARKS_MODAL),
});

const boundModalActions = bindForemanModalActionsToId({ id: BOOKMARKS_MODAL });

const mapDispatchToProps = {
  ...bookmarksActions,
  ...boundModalActions, // gives us setModalOpen and setModalClosed
};

export const reducers = { bookmarks: reducer };

export default connect(mapStateToProps, mapDispatchToProps)(Bookmarks);
