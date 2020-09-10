import { shallow } from '@theforeman/test';
import React from 'react';

import AlertBody from './AlertBody';

describe('AlertBody', () => {
  const testAlertBodyRenderer = component => {
    const wrapper = shallow(component);

    expect(wrapper).toMatchSnapshot();
  };

  it('should render with title and message', () =>
    testAlertBodyRenderer(
      <AlertBody title="some title" message="some message" />
    ));

  it('should render with childrens', () =>
    testAlertBodyRenderer(
      <AlertBody>
        <span>a Child</span>
      </AlertBody>
    ));

  it('should render with link', () =>
    testAlertBodyRenderer(
      <AlertBody link={{ children: 'link text', href: '#' }} />
    ));

  it('should render With all props', () =>
    testAlertBodyRenderer(
      <AlertBody
        title="some title"
        message="some message"
        link={{ children: 'link text', href: '#' }}
      >
        <span>a Child</span>
      </AlertBody>
    ));
});
