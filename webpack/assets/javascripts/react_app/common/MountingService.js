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
    mountNode(component, reactNode, data, flattenData);
    mountedNodes.push(reactNode);
  } else {
    // eslint-disable-next-line no-console
    console.log(
      `Cannot find '${selector}' element for mounting the '${component}'`
    );
  }
}

export function mountNode(component, reactNode, data, flattenData = false) {
  ReactDOM.render(
    componentRegistry.markup(component, {
      data,
      store,
      flattenData,
    }),
    reactNode
  );
}

/**
 * This is a html tag (Web component) that can be used for mounting react component from ComponentRegistry.
 */
class ReactComponentElement extends HTMLElement {
  get componentName() {
    return this.getAttribute('name');
  }
  get props() {
    return this.dataset.props !== '' ? JSON.parse(this.dataset.props) : {};
  }
  get flattenData() {
    return this.hasAttribute('flatten-data');
  }
  get mountPoint() {
    if (!this._mountPoint) {
      this._mountPoint = document.createElement('span');
      this.appendChild(this._mountPoint);
    }

    return this._mountPoint;
  }

  connectedCallback() {
    try {
      mountNode(
        this.componentName,
        this.mountPoint,
        this.props,
        this.flattenData
      );
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(
        `Unable to mount react-component: ${this.componentName}`,
        error
      );
    }
  }

  disconnectedCallback() {
    try {
      ReactDOM.unmountComponentAtNode(this.mountPoint);
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(
        `Unable to unmount react-component: ${this.componentName}`,
        error
      );
    }
  }
}

window.customElements.define('react-component', ReactComponentElement);
