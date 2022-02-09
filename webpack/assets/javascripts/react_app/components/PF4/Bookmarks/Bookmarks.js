import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Dropdown, DropdownToggle } from '@patternfly/react-core';
import { OutlinedBookmarkIcon } from '@patternfly/react-icons';
import BookmarkModal from '../../Bookmarks/components/SearchModal';
import { STATUS } from '../../../constants';
import { noop } from '../../../common/helpers';
import {
  addBookmarkItem,
  savedBookmarksItems,
  manageBookmarksItem,
} from './BookmarkItems';
import history from '../../../history';
import { stringifyParams } from '../../../common/urlHelpers';
import { translate as __ } from '../../../common/I18n';

const Bookmarks = ({
  id,
  bookmarks,
  status,
  url,
  controller,
  getBookmarks,
  canCreate,
  errors,
  documentationUrl,
  onBookmarkClick,
  setModalOpen,
  setModalClosed,
}) => {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  const onToggle = isOpen => {
    setIsDropdownOpen(isOpen);
    if (bookmarks.length === 0 && status !== STATUS.PENDING) {
      getBookmarks();
    }
  };

  const manageBookmarks = () => {
    const query = stringifyParams({ searchQuery: `controller=${controller}` });
    history.push({ pathname: '/bookmarks', search: query });
  };

  const dropdownItems = [
    addBookmarkItem({ canCreate, setModalOpen }),
    savedBookmarksItems({
      bookmarks,
      onBookmarkClick,
      status,
      errors,
    }),
    manageBookmarksItem({
      canCreate,
      onClick: manageBookmarks,
      documentationUrl,
    }),
  ];

  return (
    <React.Fragment>
      <BookmarkModal
        id={id}
        controller={controller}
        url={url}
        setModalClosed={setModalClosed}
        bookmarks={bookmarks}
      />
      <Dropdown
        isOpen={isDropdownOpen}
        onSelect={() => setIsDropdownOpen(false)}
        toggle={
          <DropdownToggle
            onToggle={onToggle}
            title={__('Bookmarks')}
            aria-label="bookmarks dropdown toggle"
          >
            <OutlinedBookmarkIcon />
          </DropdownToggle>
        }
        id={controller}
        dropdownItems={dropdownItems}
        isGrouped
      />
    </React.Fragment>
  );
};

Bookmarks.propTypes = {
  id: PropTypes.string.isRequired,
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
