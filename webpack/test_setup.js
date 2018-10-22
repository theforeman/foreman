import 'babel-polyfill';

import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

jest.mock('jed');
jest.mock('./assets/javascripts/react_app/common/I18n');

configure({ adapter: new Adapter() });
