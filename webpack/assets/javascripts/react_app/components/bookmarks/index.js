import React from 'react';
import { connect } from 'react-redux';
import { Dropdown, MenuItem } from 'patternfly-react';
import SearchModal from './SearchModal';
import Bookmark from './Bookmark';
import Loader from '../common/Loader';
import * as BookmarkActions from '../../redux/actions/bookmarks';
import DocumentationUrl from '../common/DocumentationLink';
import { STATUS } from '../../constants';

const getLoadingStatus = (errors, data) => {
  if (data.length > 0) {
    return STATUS.RESOLVED;
  }
  if (errors) {
    return STATUS.ERROR;
  }
  return STATUS.PENDING;
};

class BookmarkContainer extends React.Component {
  componentDidMount() {
    const { url, controller, getBookmarks } = this.props;

    getBookmarks(url, controller);
  }

  onClick() {
    if (this.props.showModal) {
      this.props.modalClosed();
    } else {
      this.props.modalOpened();
    }
  }

  render() {
    const {
      controller, url, showModal, modalClosed, canCreate, bookmarks, errors,
    } = this.props;

    return showModal ? (
      <SearchModal show={showModal} controller={controller} url={url} onHide={modalClosed} />
    ) : (
      <Dropdown pullRight id={controller}>
        <Dropdown.Toggle />
        <Dropdown.Menu>
          <MenuItem header>{__('Saved Bookmarks')}</MenuItem>
          {getLoadingStatus(errors, bookmarks) === STATUS.PENDING && (
            <Loader spinnerSize="xs" status={STATUS.PENDING} />
          )}
          {getLoadingStatus(errors, bookmarks) === STATUS.RESOLVED &&
            bookmarks.map(({ name, query }) => <Bookmark key={name} text={name} query={query} />)}
          {getLoadingStatus(errors, bookmarks) === STATUS.ERROR &&
            // eslint-disable-next-line no-undef
            Jed.sprintf(__('Failed to load bookmarks: %s'), errors)}
          <MenuItem divider={true} />
          {canCreate && (
            <MenuItem key="newBookmark" id="newBookmark" onClick={this.onClick.bind(this)}>
              {__('Bookmark this search')}
            </MenuItem>
          )}
          <DocumentationUrl id="bookmarkDocumentation" href={this.props.documentationUrl} />
        </Dropdown.Menu>
      </Dropdown>
    );
  }
}

const mapStateToProps = ({ bookmarks }, { data: { controller } }) => ({
  errors: bookmarks[controller] && bookmarks[controller].errors,
  bookmarks: (bookmarks[controller] && bookmarks[controller].results) || [],
  showModal: bookmarks.showModal,
});

// I'm flatting the props that come from data attribute, this is done to avoid
// having special handling for this.props.data vs this.props in the codebase.
const mergeProps = (stateProps, dispatchProps, { data }) =>
  Object.assign(stateProps, data, dispatchProps);

export default connect(mapStateToProps, BookmarkActions, mergeProps)(BookmarkContainer);
