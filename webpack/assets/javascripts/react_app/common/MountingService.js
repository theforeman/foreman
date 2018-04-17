import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import React from 'react';

import store from '../redux';
import componentRegistry from '../components/componentRegistry';

export { default as registerReducer } from '../redux/reducers/registerReducer';

let mountedNodesCache = [];

// In order to support turbolinks with react, need to
// unmount all root components before turbolinks do the unload
// TODO: remove it when migrating into (webpacker-react or react-rails)
document.addEventListener('page:before-unload', () => unmountComponents());

const unmountComponentsByNodes = nodes =>
  nodes.forEach(node => ReactDOM.unmountComponentAtNode(node));

/**
 * Will unmount all react-components from the dom
 * @param  {string} selector unmount component inside the selector
 * @return {number}          amount of unmounted nodes
 */
export const unmountComponents = (selector) => {
  const nodesToUnmount = [];
  const nodesToKeep = [];

  if (selector) {
    const reactNode = document.querySelector(selector);

    mountedNodesCache.forEach((node) => {
      if (reactNode.contains(node)) {
        nodesToUnmount.push(node);
      } else {
        nodesToKeep.push(node);
      }
    });
  } else {
    nodesToUnmount.push(...mountedNodesCache);
  }

  unmountComponentsByNodes(nodesToUnmount);
  mountedNodesCache = nodesToKeep;

  return nodesToUnmount.length;
};

export const mount = (component, selector, data) => {
  const reactNode = document.querySelector(selector);

  if (reactNode) {
    ReactDOM.unmountComponentAtNode(reactNode);
    ReactDOM.render(
      <Provider store={store}>{componentRegistry.markup(component, data, store)}</Provider>,
      reactNode,
    );

    mountedNodesCache.push(reactNode);
  } else {
    // eslint-disable-next-line no-console
    console.log(`Cannot find '${selector}' element for mounting the '${component}'`);
  }
};
