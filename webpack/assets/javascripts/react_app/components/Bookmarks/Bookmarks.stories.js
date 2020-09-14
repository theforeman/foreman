import React from 'react';
import { Button } from 'patternfly-react';
import BookmarkForm from './components/BookmarkForm';
import { BOOKMARKS_MODAL } from './BookmarksConstants';
import { useForemanModal } from '../ForemanModal/ForemanModalHooks';
import BookmarkModal from './components/SearchModal';
import storeDecorator from '../../../../../stories/storeDecorator';
import Story from '../../../../../stories/components/Story';

export default {
  title: 'Page chunks/Bookmarks',
  decorators: [storeDecorator],
};

export const form = () => (
  <Story>
    <BookmarkForm controller="hosts" url="/api/bookmarks" />
  </Story>
);

export const modalForm = () =>
  React.createElement(() => {
    const { setModalOpen } = useForemanModal({ id: BOOKMARKS_MODAL });
    return (
      <Story>
        <Button bsStyle="primary" onClick={setModalOpen}>
          Show Modal
        </Button>
        <BookmarkModal controller="hosts" url="/api/bookmarks" />
      </Story>
    );
  });

modalForm.story = {
  name: 'ModalForm',
};
