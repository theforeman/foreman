import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';

import MessageBox from './MessageBox';

jest.unmock('./MessageBox');

function setup(msg, type) {
  return shallow(<MessageBox msg={msg} icontype={type} />);
}

describe('MessageBox', () => {
  describe('the message', () => {
    it('displays this is some text', () => {
      const wrapper = setup('this is some text', 'info');

      expect(toJson(wrapper)).toMatchSnapshot();
    });

    it('displays This is another message', () => {
      const wrapper = setup('This is another message', 'warning');

      expect(toJson(wrapper)).toMatchSnapshot();
    });
  });

  describe('the icon', () => {
    it('has pficon and pficon-info classes', () => {
      const wrapper = setup('this is some text', 'info');

      expect(toJson(wrapper)).toMatchSnapshot();
    });

    it('has pficon and pficon-info classes', () => {
      const wrapper = setup('this is some text', 'error-circle-o');

      expect(toJson(wrapper)).toMatchSnapshot();
    });
  });
});
