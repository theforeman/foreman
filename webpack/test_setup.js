import 'babel-polyfill';

import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

configure({ adapter: new Adapter() });

// Mocking translation function
global.__ = str => str;
global.n__ = str => str;
global.Jed = { sprintf: str => str };
