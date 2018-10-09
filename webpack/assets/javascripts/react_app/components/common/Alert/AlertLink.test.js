import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';

import AlertLink from './AlertLink';

describe('AlertLink', () => {
  it('should render with href', () => {
    const wrapper = shallow(<AlertLink href="#">some link</AlertLink>);

    expect(toJson(wrapper)).toMatchSnapshot();
  });

  it('should render with onClick', () => {
    const handleClick = jest.fn();
    const wrapper = shallow(
      <AlertLink onClick={handleClick}>some link</AlertLink>
    );

    expect(toJson(wrapper)).toMatchSnapshot();

    wrapper.find('a').simulate('click');

    expect(handleClick).toHaveBeenCalled();
  });
});
