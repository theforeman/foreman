import React from 'react';
import { PlusIcon } from '@patternfly/react-icons';
import { Spinner } from '@patternfly/react-core';
import {
  DropdownItem,
  DropdownGroup,
  DropdownSeparator,
} from '@patternfly/react-core/deprecated';
import { sprintf, translate as __ } from '../../../common/I18n';
import { STATUS } from '../../../constants';
import DocumentationUrl from '../DocumentationLink';
import './bookmarks.scss';

export const addBookmarkItem = ({ setModalOpen }) => (
  <DropdownGroup key="create-bookmark">
    <DropdownItem
      ouiaId="new-bookmark-dropdown-item"
      key="newBookmark"
      id="newBookmark"
      onClick={setModalOpen}
    >
      <PlusIcon /> {__('Bookmark this search')}
    </DropdownItem>
    <DropdownSeparator
      ouiaId="new-bookmark-dropdown-separator"
      key="separator"
    />
  </DropdownGroup>
);

const pendingItem = (
  <DropdownItem
    ouiaId="spinner-dropdown-item"
    key="spinner"
    className="loader-root"
    isDisabled
  >
    <Spinner size="xs" aria-label="loading bookmarks" />
  </DropdownItem>
);

const bookmarksList = ({ bookmarks, onBookmarkClick }) => {
  const hasLongerName = bookmarks.some(bookmark => bookmark.name.length > 90);

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
      errors.length > 90 ? 'adapt-long-bookmark' : ''
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
    {[
      status === STATUS.PENDING && [pendingItem],
      status === STATUS.RESOLVED && [
        bookmarksList({ bookmarks, onBookmarkClick }),
      ],
      status === STATUS.ERROR && [errorItem(errors)],
    ].filter(item => item)}
  </DropdownGroup>
);

export const manageBookmarksItem = ({ onClick, documentationUrl }) => (
  <DropdownGroup key="manage bookmarks">
    <DropdownSeparator
      ouiaId="manage-bookmarks-dropdown-separator"
      key="separator"
    />

    <DropdownItem
      ouiaId="manage-bookmarks-dropdown-item"
      key="manageBookmarks"
      id="manageBookmarks"
      onClick={onClick}
    >
      {__('Manage Bookmarks')}
    </DropdownItem>

    <DocumentationUrl href={documentationUrl} />
  </DropdownGroup>
);
