import React from 'react';
import { storiesOf } from '@storybook/react';
import BookmarkForm from './components/BookmarkForm';
import BookmarkModal from './components/SearchModal';
import storeDecorator from '../../../../../stories/storeDecorator';
import Story from '../../../../../stories/components/Story';

storiesOf('Page chunks/Bookmarks', module)
  .addDecorator(storeDecorator)
  .add('Form', () => (
    <Story>
      <BookmarkForm controller="hosts" url="/api/bookmarks" />
    </Story>
  ))
  .add('ModalForm', () => (
    <Story>
      <BookmarkModal controller="hosts" url="/api/bookmarks" />
    </Story>
  ));
