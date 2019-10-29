import ReactDOM from 'react-dom';
import store from '../redux';
import componentRegistry from '../components/componentRegistry';

export { default as registerReducer } from '../redux/reducers/registerReducer';

export function mount(component, selector, data, flattenData = false) {
  const reactNode = document.querySelector(selector);
  if (reactNode) {
    ReactDOM.unmountComponentAtNode(reactNode);

    mountNode(component, reactNode, data, flattenData);
  } else {
    // eslint-disable-next-line no-console
    console.log(
      `Cannot find '${selector}' element for mounting the '${component}'`
    );
  }
}

function mountNode(component, reactNode, data, flattenData) {
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
  get mountPoint() {
    if (!this._mountPoint) {
      this._mountPoint = this;
    }

    return this._mountPoint;
  }

  connectedCallback() {
    try {
      mountNode(this.componentName, this, this.props, true);
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

if (!window.customElements.get('react-component')) {
  window.customElements.define('react-component', ReactComponentElement);
}
