import React from 'react';
import { Provider } from 'react-redux';
import Store from '../assets/javascripts/react_app/redux';

const storeDecorator = getStory => (<Provider store={Store}>{getStory()}</Provider>);

export default storeDecorator;
