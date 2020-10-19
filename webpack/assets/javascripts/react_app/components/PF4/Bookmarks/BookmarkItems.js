import React from 'react';
import EllipisWithTooltip from 'react-ellipsis-with-tooltip';
import { DropdownItem, DropdownGroup, Spinner } from '@patternfly/react-core';
import { sprintf, translate as __ } from '../../../common/I18n';
import { STATUS } from '../../../constants';
import DocumentationUrl from '../DocumentationLink';

export const actionItems = ({ canCreate, setModalOpen, documentationUrl }) => (
  <DropdownGroup key="group 1">
    {canCreate && (
      <DropdownItem key="newBookmark" id="newBookmark" onClick={setModalOpen}>
        {__('Bookmark this search')}
      </DropdownItem>
    )}
    <DocumentationUrl href={documentationUrl} />
  </DropdownGroup>
);

const pendingItem = (
  <DropdownItem key="spinner" className="loader-root" isDisabled>
    <Spinner size="xs" />
  </DropdownItem>
);

const bookmarksList = ({ bookmarks, onBookmarkClick }) =>
  (bookmarks.length > 0 &&
    bookmarks.map(({ name, query }) => (
      <DropdownItem key={name} onClick={() => onBookmarkClick(query)}>
        <EllipisWithTooltip>{name}</EllipisWithTooltip>
      </DropdownItem>
    ))) || (
    <DropdownItem key="not found" isDisabled>
      {__('None found')}
    </DropdownItem>
  );

const errorItem = errors => (
  <DropdownItem key="bookmarks-errors" isDisabled>
    <EllipisWithTooltip>
      {sprintf('Failed to load bookmarks: %s', errors)}
    </EllipisWithTooltip>
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
