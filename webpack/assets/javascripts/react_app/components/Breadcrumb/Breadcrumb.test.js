import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';
import { mockedBreadcrumbsMenu, headerTitle } from './Breadcrumbs.fixtures';
import ForemanBreadcrumb from './';

jest.unmock('./');

describe('render breadcrumbs', () => {
  it('renders breadcrumbs menu', () => {
    const wrapper = shallow(<ForemanBreadcrumb data={mockedBreadcrumbsMenu}/>);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('renders h1 title', () => {
    const wrapper = shallow(<ForemanBreadcrumb data={headerTitle}/>);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
