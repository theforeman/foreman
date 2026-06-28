import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import MessageBox from './index';

jest.unmock('./index');

describe('MessageBox', () => {
  describe('the message', () => {
    it('displays this is some text', () => {
      render(<MessageBox msg="this is some text" icontype="info" />);

      expect(screen.getByText('this is some text')).toBeInTheDocument();
    });

    it('displays This is another message', () => {
      render(<MessageBox msg="This is another message" icontype="warning" />);

      expect(screen.getByText('This is another message')).toBeInTheDocument();
    });
  });

  describe('the icon', () => {
    it('has pficon and pficon-info classes', () => {
      const { container } = render(
        <MessageBox msg="this is some text" icontype="info" />
      );

      expect(
        container.querySelector('.message-box-icon')
      ).toHaveClass('pficon', 'pficon-info');
    });

    it('has pficon and pficon-info classes with error icon', () => {
      const { container } = render(
        <MessageBox msg="this is some text" icontype="error-circle-o" />
      );

      expect(
        container.querySelector('.message-box-icon')
      ).toHaveClass('pficon', 'pficon-error-circle-o');
    });
  });
});
