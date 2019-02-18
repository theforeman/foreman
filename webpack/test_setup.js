import '@theforeman/vendor/jest-setup';

import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

jest.mock('@theforeman/vendor/jed');
jest.mock('./assets/javascripts/react_app/common/I18n');

configure({ adapter: new Adapter() });
