import 'babel-polyfill';
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

jest.mock('jed');
jest.mock('./assets/javascripts/react_app/common/I18n');
jest.mock('./assets/javascripts/foreman_tools', () => ({
  foremanUrl: url => url,
}));

configure({ adapter: new Adapter() });

// https://github.com/facebook/jest/issues/6121
// eslint-disable-next-line no-console
const { error } = console;
// eslint-disable-next-line no-console
console.error = (message, ...args) => {
  error.apply(console, args); // keep default behaviour
  const err = message instanceof Error ? message : new Error(message);
  throw err;
};
