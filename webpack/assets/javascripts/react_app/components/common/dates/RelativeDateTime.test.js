// Configure Enzyme
import { mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import React from 'react';
import RelativeDateTime from './RelativeDateTime';
import { i18nProviderWrapperFactory } from '../../../common/i18nProviderWrapperFactory';
import { intl } from '../../../common/I18n';

describe('RelativeDateTime', () => {
  const date = new Date('2017-10-13 00:54:55 -1100');
  const now = new Date('2017-10-28 00:00:00 -1100');
  const IntlDate = i18nProviderWrapperFactory(now, 'UTC')(RelativeDateTime);

  it('formats date', () => {
    const wrapper = mount(
      <IntlDate date={date} defaultValue="Default value" />
    );

    intl.ready.then(() => {
      wrapper.update();
      expect(toJson(wrapper.find('RelativeDateTime'))).toMatchSnapshot();
    });
  });

  it('renders default value', () => {
    const wrapper = mount(
      <IntlDate date={null} defaultValue="Default value" />
    );

    intl.ready.then(() => {
      wrapper.update();
      expect(toJson(wrapper.find('RelativeDateTime'))).toMatchSnapshot();
    });
  });
});
