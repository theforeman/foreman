import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import EllipisWithTooltip from 'react-ellipsis-with-tooltip';
import { Dropdown, MenuItem, Spinner, Icon } from 'patternfly-react';
import SearchModal from './SearchModal';
import Bookmark from './Bookmark';
import * as BookmarkActions from '../../redux/actions/bookmarks';
import DocumentationUrl from '../common/DocumentationLink';
import { STATUS } from '../../constants';
import { bindMethods, noop } from '../../common/helpers';
import { sprintf, translate as __ } from '../../../react_app/common/I18n';

class BookmarkContainer extends React.Component {
  constructor(props) {
    super(props);
    bindMethods(this, ['handleNewBookmarkClick', 'loadBookmarks']);
  }

  loadBookmarks() {
    const { bookmarks, status, url, controller, getBookmarks } = this.props;

    if (bookmarks.length === 0 && status !== STATUS.PENDING) {
      getBookmarks(url, controller);
    }
  }

  handleNewBookmarkClick() {
    const { showModal, modalClosed, modalOpened, searchQuery } = this.props;

    if (showModal) {
      modalClosed();
    } else {
      modalOpened(searchQuery);
    }
  }

  render() {
    const {
      controller,
      url,
      showModal,
      modalClosed,
      canCreate,
      bookmarks,
      errors,
      status,
      documentationUrl,
      onBookmarkClick,
    } = this.props;

    return showModal ? (
      <SearchModal
        show={showModal}
        controller={controller}
        url={url}
        onHide={modalClosed}
      />
    ) : (
      <Dropdown pullRight id={controller} onClick={this.loadBookmarks}>
        <Dropdown.Toggle title={__('Bookmarks')}>
          <Icon type="fa" name="bookmark" />
        </Dropdown.Toggle>
        <Dropdown.Menu className="scrollable-dropdown">
          {canCreate && (
            <MenuItem
              key="newBookmark"
              id="newBookmark"
              onClick={this.handleNewBookmarkClick}
            >
              {__('Bookmark this search')}
            </MenuItem>
          )}
          <DocumentationUrl href={documentationUrl} />
          <MenuItem divider />
          <MenuItem header>{__('Saved Bookmarks')}</MenuItem>
          {status === STATUS.PENDING && (
            <li className="loader-root">
              <Spinner size="xs" loading />
            </li>
          )}
          {status === STATUS.RESOLVED &&
            ((bookmarks.length > 0 &&
              bookmarks.map(({ name, query }) => (
                <Bookmark
                  key={name}
                  text={name}
                  query={query}
                  onClick={onBookmarkClick}
                />
              ))) || <MenuItem disabled> {__('None found')}</MenuItem>)}
          {status === STATUS.ERROR && (
            <MenuItem key="bookmarks-errors">
              <EllipisWithTooltip>
                {sprintf('Failed to load bookmarks: %s', errors)}
              </EllipisWithTooltip>
            </MenuItem>
          )}
        </Dropdown.Menu>
      </Dropdown>
    );
  }
}

BookmarkContainer.propTypes = {
  controller: PropTypes.string.isRequired,
  onBookmarkClick: PropTypes.func.isRequired,
  url: PropTypes.string.isRequired,
  searchQuery: PropTypes.string,
  showModal: PropTypes.bool,
  canCreate: PropTypes.bool,
  bookmarks: PropTypes.array,
  errors: PropTypes.string,
  status: PropTypes.string,
  documentationUrl: PropTypes.string,
  modalClosed: PropTypes.func,
  modalOpened: PropTypes.func,
  getBookmarks: PropTypes.func,
};

BookmarkContainer.defaultProps = {
  searchQuery: '',
  showModal: false,
  canCreate: false,
  bookmarks: [],
  errors: '',
  status: null,
  documentationUrl: '',
  modalClosed: noop,
  modalOpened: noop,
  getBookmarks: noop,
};

const mapStateToProps = (
  { bookmarks },
  { data: { controller, searchQuery } }
) => ({
  errors: bookmarks[controller] && bookmarks[controller].errors,
  bookmarks: (bookmarks[controller] && bookmarks[controller].results) || [],
  status: bookmarks[controller] && bookmarks[controller].status,
  showModal: bookmarks.showModal,
  searchQuery,
});

// I'm flatting the props that come from data attribute, this is done to avoid
// having special handling for this.props.data vs this.props in the codebase.
const mergeProps = (stateProps, dispatchProps, { data, onBookmarkClick }) =>
  Object.assign(stateProps, { ...data, onBookmarkClick }, dispatchProps);

export default connect(
  mapStateToProps,
  BookmarkActions,
  mergeProps
)(BookmarkContainer);
