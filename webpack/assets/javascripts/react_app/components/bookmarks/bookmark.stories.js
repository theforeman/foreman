import React from 'react';
import { storiesOf } from '@storybook/react';
import BookmarkForm from './form';
import BookmarkModal from './SearchModal';
import storeDecorator from '../../../../../stories/storeDecorator';

storiesOf('Bookmarks', module)
  .addDecorator(storeDecorator)
  .add('Form', () => <BookmarkForm controller="hosts" url="/api/bookmarks" />)
  .add('ModalForm', () => <BookmarkModal controller="hosts" url="/api/bookmarks" />);
