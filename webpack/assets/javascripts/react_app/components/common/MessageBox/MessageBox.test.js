import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import MessageBox from './index';

jest.unmock('./index');

describe('MessageBox', () => {
  describe('the message', () => {
    it('displays message text correctly', () => {
      render(<MessageBox msg="this is some text" icontype="info" />);

      // Test that the message text is displayed
      expect(screen.getByText('this is some text')).toBeInTheDocument();

      // Test that the component renders as expected
      const messageBox = screen.getByText('this is some text').closest('div');
      expect(messageBox).toBeInTheDocument();
    });

    it('displays different message text', () => {
      render(<MessageBox msg="This is another message" icontype="warning" />);

      // Test that the different message text is displayed
      expect(screen.getByText('This is another message')).toBeInTheDocument();
    });
  });

  describe('the icon', () => {
    it('displays info icon with correct classes', () => {
      render(<MessageBox msg="this is some text" icontype="info" />);

      // Test that message is displayed
      expect(screen.getByText('this is some text')).toBeInTheDocument();

      // Test that icon element exists with correct classes
      // Note: Using querySelector since icons might not have accessible roles
      const container = screen.getByText('this is some text').closest('div');
      const icon = container.querySelector('.pficon-info');
      expect(icon).toBeInTheDocument();
      expect(icon).toHaveClass('pficon', 'pficon-info');
    });

    it('displays error icon with correct classes', () => {
      render(<MessageBox msg="this is some text" icontype="error-circle-o" />);

      // Test that message is displayed
      expect(screen.getByText('this is some text')).toBeInTheDocument();

      // Test that error icon element exists with correct classes
      const container = screen.getByText('this is some text').closest('div');
      const icon = container.querySelector('.pficon-error-circle-o');
      expect(icon).toBeInTheDocument();
      expect(icon).toHaveClass('pficon', 'pficon-error-circle-o');
    });

    it('displays warning icon with correct classes', () => {
      render(<MessageBox msg="warning message" icontype="warning" />);

      // Test that message is displayed
      expect(screen.getByText('warning message')).toBeInTheDocument();

      // Test that warning icon element exists with correct classes
      const container = screen.getByText('warning message').closest('div');
      const icon = container.querySelector('.pficon-warning-triangle-o');
      expect(icon).toBeInTheDocument();
      expect(icon).toHaveClass('pficon', 'pficon-warning-triangle-o');
    });
  });

  describe('edge cases', () => {
    it('handles empty message gracefully', () => {
      render(<MessageBox msg="" icontype="info" />);

      // Should still render the component structure even with empty message
      const container = document.querySelector('.pficon-info')?.closest('div');
      expect(container).toBeInTheDocument();
    });

    it('handles missing icontype prop', () => {
      render(<MessageBox msg="message without icon type" />);

      // Should still display the message
      expect(screen.getByText('message without icon type')).toBeInTheDocument();
    });
  });
});
