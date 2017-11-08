import React from 'react';
import ReactDOM from 'react-dom';
import store from '../redux';
import componentRegistry from '../components/componentRegistry';
import { Provider } from 'react-redux';

export function mount(component, selector, data) {
  const reactNode = document.querySelector(selector);

  if (reactNode) {
    ReactDOM.unmountComponentAtNode(reactNode);
    ReactDOM.render(
      <Provider store={store}>
        {componentRegistry.markup(component, data, store)}
      </Provider>,
      reactNode
    );
  } else {
    // eslint-disable-next-line no-console
    console.log(
      `Cannot find \'${selector}\' element for mounting the \'${component}\'`
    );
  }
}
