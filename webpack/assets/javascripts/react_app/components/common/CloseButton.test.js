jest.unmock('./CloseButton');

import React from 'react';
import { shallow } from 'enzyme';
import CloseButton from './CloseButton';

describe('CloseButton', () => {
  it('calls click function', () => {
    const onClick = jest.fn();
    const wrapper = shallow(<CloseButton onClick={onClick}/>);

    wrapper.simulate('click');
    expect(onClick).toHaveBeenCalled();
  });
});
