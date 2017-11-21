import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

configure({ adapter: new Adapter() });

// Mocking translation function
global.__ = str => str; // eslint-disable-line
