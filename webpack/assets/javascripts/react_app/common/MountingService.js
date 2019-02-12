import ReactDOM from 'react-dom';
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
      componentRegistry.markup(component, {
        data,
        store,
        flattenData,
      }),
      reactNode
    );

    mountedNodes.push(reactNode);
  } else {
    // eslint-disable-next-line no-console
    console.warn(
      `Cannot find '${selector}' element for mounting the '${component}'`
    );
  }
}

export function unmount(selector) {
  const reactNode = document.querySelector(selector);
  let i;

  if (reactNode) {
    for (i = 0; i < mountedNodes.length - 1; i++) {
      if (mountedNodes[i] === reactNode) {
        ReactDOM.unmountComponentAtNode(reactNode);
        mountedNodes.splice(i, 1);
        break;
      }
    }
  } else {
    // eslint-disable-next-line no-console
    console.warn(`Cannot find '${selector}' element for react unmounting`);
  }
}
