import React from 'react';
import { Provider } from 'react-redux';
import Bookmarks from './Bookmarks';
import Story from '../../../../../../stories/components/Story';
import store from '../../../redux';

export default {
  title: 'Components|PF4 Bookmarks',
  decorators: [],
};

export const defaultStory = () => (
  <Provider store={store}>
    <Story>
      <Bookmarks
        controller="storybook"
        onBookmarkClick={() => null}
        url=""
        canCreate
        bookmarks={[
          {
            name: 'recent hosts',
            query: '',
          },
          {
            name: 'managed hosts',
            query: '',
          },
          {
            name: 'disabled hosts',
            query: '',
          },
        ]}
        status="RESOLVED"
        setModalOpen={() => null}
        setModalClosed={() => null}
      />
    </Story>
  </Provider>
);

defaultStory.story = {
  name: 'Default',
};

export const pendingStory = () => (
  <Provider store={store}>
    <Story>
      <Bookmarks
        controller="storybook"
        onBookmarkClick={() => null}
        url=""
        canCreate
        bookmarks={[]}
        status="PENDING"
        setModalOpen={() => null}
        setModalClosed={() => null}
      />
    </Story>
  </Provider>
);

pendingStory.story = {
  name: 'Pending',
};

export const errorStory = () => (
  <Provider store={store}>
    <Story>
      <Bookmarks
        controller="storybook"
        onBookmarkClick={() => null}
        url=""
        canCreate
        bookmarks={[]}
        status="ERROR"
        errors="Some error!"
        setModalOpen={() => null}
        setModalClosed={() => null}
      />
    </Story>
  </Provider>
);

errorStory.story = {
  name: 'Error',
};
