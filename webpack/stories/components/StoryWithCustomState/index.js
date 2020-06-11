import React from 'react';
import PropTypes from 'prop-types';
import { Provider } from 'react-redux';
import { action } from '@theforeman/stories';
import Story from '../Story';

// A super-simple mock of a redux store with a custom state.
const StoryWithCustomState = ({ state, children }) => {
  const subscribe = () => 0;
  const dispatch = () => action('dispatch');

  return (
    <Provider
      store={{
        getState: () => state,
        subscribe,
        dispatch,
      }}
    >
      <Story>{children}</Story>
    </Provider>
  );
};

StoryWithCustomState.propTypes = {
  state: PropTypes.object.isRequired,
  children: PropTypes.node.isRequired,
};

export default StoryWithCustomState;
