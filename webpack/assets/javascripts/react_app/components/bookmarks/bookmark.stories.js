import React from 'react';
import { storiesOf } from '@storybook/react';
import { Provider } from 'react-redux';
import Store from '../../redux';
import BookmarkForm from './form';
import BookmarkModal from './SearchModal';

storiesOf('Bookmarks', module)
  .addDecorator(getStory => <Provider store={Store}>{getStory()}</Provider>)
  .add('Form', () => <BookmarkForm controller="hosts" url="/api/bookmarks" />)
  .add('ModalForm', () => <BookmarkModal controller="hosts" url="/api/bookmarks" />);
