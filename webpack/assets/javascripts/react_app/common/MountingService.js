import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import React from 'react';

import store from '../redux';
import componentRegistry from '../components/componentRegistry';

export { default as registerReducer } from '../redux/reducers/registerReducer';

const mountedNodes = [];

// In order to support turbolinks with react, need to
// unmount all root components before turbolinks do the unload
// TODO: remove it when migrating into (webpacker-react or react-rails)
document.addEventListener('page:before-unload', () => {
  let node = mountedNodes.shift();

  while (node) {
    ReactDOM.unmountComponentAtNode(node);
    node = mountedNodes.shift();
  }
});

export function mount(component, selector, data, flattenData = false) {
  const reactNode = document.querySelector(selector);

  if (reactNode) {
    ReactDOM.unmountComponentAtNode(reactNode);
    ReactDOM.render(
      <Provider store={store}>
        {componentRegistry.markup(
          component,
          data,
          store,
          flattenData,
        )}
      </Provider>,
      reactNode,
    );

    mountedNodes.push(reactNode);
  } else {
    // eslint-disable-next-line no-console
    console.log(`Cannot find '${selector}' element for mounting the '${component}'`);
  }
}
