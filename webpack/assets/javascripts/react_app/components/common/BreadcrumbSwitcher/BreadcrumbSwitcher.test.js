import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';
import { ResourcesProps } from './BreadcrumbSwitcher.fixtures';
import BreadcrumbSwitcher from './';

describe('render resource switcher', () => {
  it('displays this is some text', () => {
    const wrapper = shallow(<BreadcrumbSwitcher {...ResourcesProps}/>);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
