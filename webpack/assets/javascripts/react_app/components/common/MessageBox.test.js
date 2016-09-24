jest.unmock('./MessageBox');

import React from 'react';
import { shallow } from 'enzyme';
import MessageBox from './MessageBox';

function setup(msg, type) {
  return shallow(<MessageBox msg={msg}
                             icontype={type}></MessageBox>);
}

describe('MessageBox', () => {
  describe('the message', () => {
    it('displays this is some text', () => {
      const wrapper = setup('this is some text', 'info');
      const message = wrapper.childAt(1);

      expect(message.text()).toBe('this is some text');
    });

    it('displays This is another message', () => {
      const wrapper = setup('This is another message', 'warning');
      const message = wrapper.childAt(1);

      expect(message.text()).toBe('This is another message');
    });
  });

  describe('the icon', () => {
    it('has pficon and pficon-info classes', () => {
      const wrapper = setup('this is some text', 'info');
      const icon = wrapper.childAt(0);

      expect(icon.is('.pficon.pficon-info')).toBe(true);
    });

    it('has pficon and pficon-info classes', () => {
      const wrapper = setup('this is some text', 'error-circle-o');
      const icon = wrapper.childAt(0);

      expect(icon.is('.pficon-error-circle-o.pficon')).toBe(true);
    });
  });
});
