import React from 'react';
import PropTypes from 'prop-types';
import EllipisWithTooltip from 'react-ellipsis-with-tooltip';
import { Dropdown, MenuItem, Spinner, Icon } from 'patternfly-react';
import SearchModal from './components/SearchModal';
import Bookmark from './components/Bookmark';
import DocumentationUrl from '../common/DocumentationLink';
import { STATUS } from '../../constants';
import { noop } from '../../common/helpers';
import { sprintf, translate as __ } from '../../../react_app/common/I18n';

const Bookmarks = props => {
  const loadBookmarks = () => {
    const { bookmarks, status, url, controller, getBookmarks } = props;

    if (bookmarks.length === 0 && status !== STATUS.PENDING) {
      getBookmarks(url, controller);
    }
  };

  const {
    controller,
    url,
    canCreate,
    bookmarks,
    errors,
    status,
    documentationUrl,
    onBookmarkClick,
    setModalOpen,
    setModalClosed,
  } = props;

  return (
    <React.Fragment>
      <SearchModal
        controller={controller}
        url={url}
        setModalClosed={setModalClosed}
        bookmarks={bookmarks}
      />
      <Dropdown pullRight id={controller} onClick={loadBookmarks}>
        <Dropdown.Toggle title={__('Bookmarks')}>
          <Icon type="fa" name="bookmark" />
        </Dropdown.Toggle>
        <Dropdown.Menu className="scrollable-dropdown">
          {canCreate && (
            <MenuItem key="newBookmark" id="newBookmark" onClick={setModalOpen}>
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
    </React.Fragment>
  );
};

Bookmarks.propTypes = {
  controller: PropTypes.string.isRequired,
  onBookmarkClick: PropTypes.func.isRequired,
  url: PropTypes.string.isRequired,
  canCreate: PropTypes.bool,
  bookmarks: PropTypes.array,
  errors: PropTypes.string,
  status: PropTypes.string,
  documentationUrl: PropTypes.string,
  getBookmarks: PropTypes.func,
  setModalOpen: PropTypes.func.isRequired,
  setModalClosed: PropTypes.func.isRequired,
};

Bookmarks.defaultProps = {
  canCreate: false,
  bookmarks: [],
  errors: '',
  status: null,
  documentationUrl: '',
  getBookmarks: noop,
};

export default Bookmarks;
