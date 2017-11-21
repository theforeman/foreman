import toJson from 'enzyme-to-json';
import { shallow, mount } from 'enzyme';
import React from 'react';

import { STATUS } from '../../constants';
import Loader from './Loader';

jest.unmock('./Loader');

function setup(status, spinnerSize) {
  const props = {
    status,
    spinnerSize,
  };

  return shallow(<Loader {...props}>
    {[
      <div key="0" className="success">Success</div>,
      <div key="1" className="failure">Failure</div>,
    ]}
  </Loader>);
}

describe('Loader', () => {
  describe('renders correct content based on status', () => {
    it('success', () => {
      const wrapper = setup(STATUS.RESOLVED);

      expect(toJson(wrapper)).toMatchSnapshot();
    });

    it('failure', () => {
      const wrapper = setup(STATUS.ERROR);

      expect(toJson(wrapper)).toMatchSnapshot();
    });

    it('pending', () => {
      const wrapper = setup(STATUS.PENDING);

      expect(toJson(wrapper)).toMatchSnapshot();
    });

    it('pending-different-spinner', () => {
      const wrapper = setup(STATUS.PENDING, 'xs');

      expect(toJson(wrapper)).toMatchSnapshot();
    });

    it('default case', () => {
      const wrapper = mount(<Loader />);

      expect(toJson(wrapper)).toMatchSnapshot();
    });
  });
});
