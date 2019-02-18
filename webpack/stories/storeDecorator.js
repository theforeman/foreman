import React from '@theforeman/vendor/react';
import { Provider } from '@theforeman/vendor/react-redux';
import Store from '../assets/javascripts/react_app/redux';

const storeDecorator = getStory => (
  <Provider store={Store}>{getStory()}</Provider>
);

export default storeDecorator;
