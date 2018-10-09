import toJson from 'enzyme-to-json';
import { shallow, mount } from 'enzyme';
import React from 'react';

import { STATUS } from '../../../constants';
import Loader from './index';

jest.unmock('./index');

const testLoaderSnapshot = (props = {}) => {
  const wrapper = shallow(
    <Loader {...props}>
      {[
        <div key="0" className="success">
          Success
        </div>,
        <div key="1" className="failure">
          Failure
        </div>,
      ]}
    </Loader>
  );

  expect(toJson(wrapper)).toMatchSnapshot();
};

describe('Loader', () => {
  describe('renders correct content based on status', () => {
    it('success', () => testLoaderSnapshot({ status: STATUS.RESOLVED }));
    it('failure', () => testLoaderSnapshot({ status: STATUS.ERROR }));
    it('pending', () => testLoaderSnapshot({ status: STATUS.PENDING }));
    it('pending-different-spinner', () =>
      testLoaderSnapshot({ status: STATUS.PENDING, spinnerSize: 'xs' }));

    it('default case', () => {
      const wrapper = mount(<Loader />);

      expect(toJson(wrapper)).toMatchSnapshot();
    });
  });
});
