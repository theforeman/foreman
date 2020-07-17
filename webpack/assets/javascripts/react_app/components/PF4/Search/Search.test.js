import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import { mock as mockApi } from '../../mockRequest';

import Search from '../Search/Search';

describe('Search component', () => {
  const getBaseProps = () => ({
    onSearch: () => {},
    getAutoCompleteParams: () => ({ endpoint: '/fake' }),
    loadSetting: jest.fn(),
  });

  describe('rendering', () => {
    it('renders correctly', () => {
      mockApi.onGet('/katello/api/v2/fake').reply(200, []);
      const component = shallow(<Search {...getBaseProps()} />);

      expect(toJson(component)).toMatchSnapshot();
    });
  });
});
