import ReactDOM from 'react-dom';
import store from '../redux';
import componentRegistry from '../components/componentRegistry';

export function mount(component, selector, data) {
  const reactNode = document.querySelector(selector);

  if (reactNode) {
    ReactDOM.unmountComponentAtNode(reactNode);
    ReactDOM.render(componentRegistry.markup(component, data, store), reactNode);
  } else {
    // eslint-disable-next-line no-console
    console.log(`Cannot find \'${selector}\' element for mounting the \'${component}\'`);
  }
}
