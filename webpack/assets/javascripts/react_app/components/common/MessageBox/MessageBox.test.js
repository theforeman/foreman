import { shallow } from '@theforeman/test';
import React from 'react';

import MessageBox from './index';

jest.unmock('./index');

const testMessageBoxSnapshot = props => {
  const wrapper = shallow(<MessageBox {...props} />);

  expect(wrapper).toMatchSnapshot();
};

describe('MessageBox', () => {
  describe('the message', () => {
    it('displays this is some text', () =>
      testMessageBoxSnapshot({ msg: 'this is some text', icontype: 'info' }));

    it('displays This is another message', () =>
      testMessageBoxSnapshot({
        msg: 'This is another message',
        icontype: 'warning',
      }));
  });

  describe('the icon', () => {
    it('has pficon and pficon-info classes', () =>
      testMessageBoxSnapshot({ msg: 'this is some text', icontype: 'info' }));

    it('has pficon and pficon-info classes with error icon', () =>
      testMessageBoxSnapshot({
        msg: 'this is some text',
        icontype: 'error-circle-o',
      }));
  });
});
