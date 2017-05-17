jest.unmock('./Loader');

import React from 'react';
import {shallow, mount} from 'enzyme';
import Loader from './Loader';
import {STATUS} from '../../constants';

function setup(status, spinnerSize) {
  const props = {
    status: status,
    spinnerSize: spinnerSize
  };

  return shallow(<Loader {...props}>
    {[
      <div key="0" className="success">Success</div>,
      <div key="1" className="failure">Failure</div>
    ]}
  </Loader>);
}

describe('Loader', () => {
  describe('renders correct content based on status', () => {
    it('success', () => {
      const wrapper = setup(STATUS.RESOLVED);

      expect(wrapper.children().length).toBe(1);
      expect(wrapper.children().equals(<div key="0" className="success">Success</div>)).toBe(true);
    });

    it('failure', () => {
      const wrapper = setup(STATUS.ERROR);

      expect(wrapper.children().length).toBe(1);
      expect(wrapper.children().equals(<div key="1" className="failure">Failure</div>)).toBe(true);
    });

    it('pending', () => {
      const wrapper = setup(STATUS.PENDING);

      expect(wrapper.children().length).toBe(1);
      expect(wrapper.children().equals(<div className="spinner spinner-lg"></div>)).toBe(true);
    });

    it('pending-different-spinner', () => {
      const wrapper = setup(STATUS.PENDING, 'xs');

      expect(wrapper.children().length).toBe(1);
      expect(wrapper.children().equals(<div className="spinner spinner-xs"></div>)).toBe(true);
    });

    it('default case', () => {
      const wrapper = mount(<Loader>
      </Loader>);

      expect(wrapper.children().children().at(0).is('.pficon.pficon-error-circle-o')).toBe(true);
      expect(wrapper.children().children().at(1).text()).toBe('Invalid Status');
    });
  });
});
