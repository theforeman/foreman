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
  static get observedAttributes() {
    return ['data-props'];
  }

  get componentName() {
    return this.getAttribute('name');
  }
  get reactProps() {
    return this.dataset.props !== '' ? JSON.parse(this.dataset.props) : {};
  }
  set reactProps(newProps) {
    this.dataset.props = JSON.stringify(newProps);
  }
  get mountPoint() {
    if (!this._mountPoint) {
      this._mountPoint = this;
    }

    return this._mountPoint;
  }

  attributeChangedCallback(name, oldValue, newValue) {
    switch (name) {
      case 'data-props':
        // if this is not the initial prop set
        if (oldValue !== null) this._render();
        break;
      default:
      // We don't know how to react to default attribute change
    }
  }

  connectedCallback() {
    this._render();
  }

  disconnectedCallback() {
    try {
      ReactDOM.unmountComponentAtNode(this.mountPoint);
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(
        `Unable to unmount foreman-react-component: ${this.componentName}`,
        error
      );
    }
  }

  _render() {
    try {
      mountNode(this.componentName, this, this.reactProps, true);
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(
        `Unable to mount foreman-react-component: ${this.componentName}`,
        error
      );
    }
  }
}

if (!window.customElements.get('foreman-react-component')) {
  window.customElements.define(
    'foreman-react-component',
    ReactComponentElement
  );
}
