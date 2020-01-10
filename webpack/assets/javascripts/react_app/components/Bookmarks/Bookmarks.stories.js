import React from 'react';
import BookmarkForm from './components/BookmarkForm';
import BookmarkModal from './components/SearchModal';
import storeDecorator from '../../../../../stories/storeDecorator';
import Story from '../../../../../stories/components/Story';

export default {
  title: 'Page chunks|Bookmarks',
  decorators: [storeDecorator],
};

export const form = () => (
  <Story>
    <BookmarkForm controller="hosts" url="/api/bookmarks" />
  </Story>
);

export const modalForm = () => (
  <Story>
    <BookmarkModal controller="hosts" url="/api/bookmarks" />
  </Story>
);

modalForm.story = {
  name: 'ModalForm',
};
