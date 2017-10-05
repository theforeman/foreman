// Configure Enzyme
import { configure, mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import toJson from 'enzyme-to-json';
import React from 'react';
import DateComponent from './Date';
import { intlProviderWrapper } from '../../../common/i18n';

configure({ adapter: new Adapter() });

describe('Date', () => {
  const date = new Date('2017-10-13 00:54:55 -1100');
  const now = new Date('2017-10-28 00:00:00 -1100');
  const IntlDate = intlProviderWrapper(now)(DateComponent);

  it('formats date', () => {
    const wrapper = mount(<IntlDate data={{ date, default: 'Default value' }} />);

    expect(toJson(wrapper.find('Date'))).toMatchSnapshot();
  });

  it('renders default value', () => {
    const wrapper = mount(<IntlDate data={{ date: null, default: 'Default value' }} />);

    expect(toJson(wrapper.find('Date'))).toMatchSnapshot();
  });
});
