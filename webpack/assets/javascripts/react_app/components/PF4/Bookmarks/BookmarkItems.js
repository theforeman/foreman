import React from 'react';
import { PlusIcon } from '@patternfly/react-icons';
import {
  Divider,
  DropdownGroup,
  DropdownItem,
  DropdownList,
  Spinner,
} from '@patternfly/react-core';
import { sprintf, translate as __ } from '../../../common/I18n';
import { STATUS } from '../../../constants';
import DocumentationUrl from '../DocumentationLink';
import './bookmarks.scss';

export const addBookmarkItem = setModalOpen => (
  <React.Fragment key="create-bookmark">
    <DropdownGroup>
      <DropdownList>
        <DropdownItem
          ouiaId="new-bookmark-dropdown-item"
          key="newBookmark"
          id="newBookmark"
          icon={<PlusIcon />}
          onClick={setModalOpen}
        >
          {__('Bookmark this search')}
        </DropdownItem>
      </DropdownList>
    </DropdownGroup>
    <Divider />
  </React.Fragment>
);

const pendingItem = (
  <DropdownItem
    ouiaId="spinner-dropdown-item"
    key="spinner"
    className="loader-root"
    isDisabled
  >
    <Spinner size="sm" aria-label="loading bookmarks" />
  </DropdownItem>
);

const MAX_BOOKMARK_NAME_LENGTH = 90;

const bookmarksList = ({ bookmarks, onBookmarkClick }) => {
  const hasLongerName = bookmarks.some(
    bookmark => bookmark.name.length > MAX_BOOKMARK_NAME_LENGTH
  );

  return (
    (bookmarks.length > 0 &&
      bookmarks.map(({ name, query }) => (
        <DropdownItem
          ouiaId={`${name}-dropdown-item`}
          className={`bookmarks-dropdown-item ${
            hasLongerName ? 'adapt-long-bookmark' : ''
          }`}
          key={name}
          onClick={() => onBookmarkClick(query)}
        >
          {name}
        </DropdownItem>
      ))) || (
      <DropdownItem ouiaId="not-found-dropdown-item" key="not found" isDisabled>
        {__('None found')}
      </DropdownItem>
    )
  );
};

const errorItem = errors => (
  <DropdownItem
    ouiaId="error-dropdown-item"
    className={`bookmarks-dropdown-item ${
      errors.length > MAX_BOOKMARK_NAME_LENGTH ? 'adapt-long-bookmark' : ''
    }`}
    key="bookmarks-errors"
    isDisabled
  >
    {sprintf('Failed to load bookmarks: %s', errors)}
  </DropdownItem>
);

export const savedBookmarksItems = ({
  bookmarks,
  onBookmarkClick,
  status,
  errors,
}) => (
  <DropdownGroup key="saved bookmarks" label={__('Saved Bookmarks')}>
    <DropdownList>
      {status === STATUS.PENDING && pendingItem}
      {status === STATUS.RESOLVED &&
        bookmarksList({ bookmarks, onBookmarkClick })}
      {status === STATUS.ERROR && errorItem(errors)}
    </DropdownList>
  </DropdownGroup>
);

export const manageBookmarksItem = ({ onClick, documentationUrl }) => (
  <React.Fragment key="manage bookmarks">
    <Divider />
    <DropdownGroup>
      <DropdownList>
        <DropdownItem
          ouiaId="manage-bookmarks-dropdown-item"
          key="manageBookmarks"
          id="manageBookmarks"
          onClick={onClick}
        >
          {__('Manage Bookmarks')}
        </DropdownItem>
        <DocumentationUrl href={documentationUrl} />
      </DropdownList>
    </DropdownGroup>
  </React.Fragment>
);
