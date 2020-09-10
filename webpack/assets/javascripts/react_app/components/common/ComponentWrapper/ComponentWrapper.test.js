import { shallow } from '@theforeman/test';
import React from 'react';
import componentRegistry from '../../componentRegistry';
import ComponentWrapper from './ComponentWrapper';

jest.mock('../../componentRegistry');

describe('ComponentWrapper', () => {
  it('should render core component', () => {
    componentRegistry.getComponent = jest.fn(() => ({
      type: 'AwesomeComponent',
    }));

    const wrapper = shallow(
      <ComponentWrapper data={{ component: 'AwesomeComponent' }} />
    );

    expect(wrapper).toMatchSnapshot();
  });

  it('should not render unregistered component', () => {
    const render = () => {
      componentRegistry.getComponent = jest.fn(() => undefined);
      shallow(<ComponentWrapper data={{ component: 'NotAwesomeComponent' }} />);
    };

    expect(render).toThrow(Error);
  });

  it('should not render self', () => {
    const render = () => {
      componentRegistry.getComponent = jest.fn(() => undefined);
      shallow(<ComponentWrapper data={{ component: 'ComponentWrapper' }} />);
    };

    expect(render).toThrow(Error);
  });
});
