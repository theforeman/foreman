import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Dropdown, DropdownToggle } from '@patternfly/react-core';
import { BookmarkIcon } from '@patternfly/react-icons';
import BookmarkModal from '../../Bookmarks/components/SearchModal';
import { STATUS } from '../../../constants';
import { noop } from '../../../common/helpers';
import { actionItems, savedBookmarksItems } from './BookmarkItems';

const Bookmarks = ({
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
  const dropdownItems = [
    actionItems({ canCreate, setModalOpen, documentationUrl }),
    savedBookmarksItems({
      bookmarks,
      onBookmarkClick,
      status,
      errors,
    }),
  ];

  return (
    <React.Fragment>
      <BookmarkModal
        controller={controller}
        url={url}
        setModalClosed={setModalClosed}
        bookmarks={bookmarks}
      />
      <Dropdown
        isOpen={isDropdownOpen}
        toggle={
          <DropdownToggle onToggle={onToggle}>
            <BookmarkIcon />
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
