import 'babel-polyfill';

import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

import * as i18n from './assets/javascripts/react_app/common/I18n';

jest.mock('jed');
jest.mock('./assets/javascripts/react_app/common/I18n');

configure({ adapter: new Adapter() });

// Mocking translation function
i18n.translate = jest.fn(str => str);
i18n.ngettext = jest.fn(str => str);
i18n.sprintf = jest.fn(str => str);
