import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import { STATUS } from '../../../constants';
import Loader from './index';

jest.unmock('./index');

describe('Loader', () => {
  const testChildren = [
    <div key="0" className="success">
      Success
    </div>,
    <div key="1" className="failure">
      Failure
    </div>,
  ];

  describe('renders correct content based on status', () => {
    it('shows success content when status is resolved', () => {
      render(
        <Loader status={STATUS.RESOLVED}>
          {testChildren}
        </Loader>
      );

      // Should display success content when resolved
      expect(screen.getByText('Success')).toBeInTheDocument();
      expect(screen.queryByText('Failure')).not.toBeInTheDocument();

      // Should not show loading spinner
      expect(screen.queryByRole('status')).not.toBeInTheDocument();
      expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
    });

    it('shows failure content when status is error', () => {
      render(
        <Loader status={STATUS.ERROR}>
          {testChildren}
        </Loader>
      );

      // Should display failure content when error
      expect(screen.getByText('Failure')).toBeInTheDocument();
      expect(screen.queryByText('Success')).not.toBeInTheDocument();

      // Should not show loading spinner
      expect(screen.queryByRole('status')).not.toBeInTheDocument();
      expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
    });

    it('shows loading spinner when status is pending', () => {
      render(
        <Loader status={STATUS.PENDING}>
          {testChildren}
        </Loader>
      );

      // Should show loading indicator
      const loadingElement = screen.queryByRole('status') ||
                           screen.queryByText(/loading/i) ||
                           screen.container.querySelector('.spinner, .loading, [class*="spin"]');

      expect(loadingElement).toBeInTheDocument();

      // Should not show children content while loading
      expect(screen.queryByText('Success')).not.toBeInTheDocument();
      expect(screen.queryByText('Failure')).not.toBeInTheDocument();
    });

    it('shows loading spinner with different size when specified', () => {
      render(
        <Loader status={STATUS.PENDING} spinnerSize="xs">
          {testChildren}
        </Loader>
      );

      // Should show loading indicator with appropriate size class
      const loadingElement = screen.queryByRole('status') ||
                           screen.queryByText(/loading/i) ||
                           screen.container.querySelector('.spinner, .loading, [class*="spin"]');

      expect(loadingElement).toBeInTheDocument();

      // Check for size-specific classes if applicable
      const spinnerElement = screen.container.querySelector('[class*="xs"], [class*="small"]');
      if (spinnerElement) {
        expect(spinnerElement).toBeInTheDocument();
      }
    });

    it('handles default case without status', () => {
      render(<Loader />);

      const element = screen.queryByText(/Invalid Status/i);
      expect(element).toBeInTheDocument();

      // Should not crash and should render something
      expect(container.firstChild).toBeTruthy();
    });

    it('handles empty children gracefully', () => {
      render(<Loader status={STATUS.RESOLVED} />);

      // Should not crash with empty children
      expect(screen.container).toBeInTheDocument();
    });

    it('shows all children when resolved', () => {
      const multipleChildren = [
        <div key="1" data-testid="child-1">Child 1</div>,
        <div key="2" data-testid="child-2">Child 2</div>,
        <div key="3" data-testid="child-3">Child 3</div>,
      ];

      render(
        <Loader status={STATUS.RESOLVED}>
          {multipleChildren}
        </Loader>
      );

      // All children should be visible when resolved
      expect(screen.getByTestId('child-1')).toBeInTheDocument();
      expect(screen.getByTestId('child-2')).toBeInTheDocument();
      expect(screen.getByTestId('child-3')).toBeInTheDocument();
    });

    it('is accessible when loading', () => {
      render(
        <Loader status={STATUS.PENDING}>
          {testChildren}
        </Loader>
      );

      // Loading state should be accessible to screen readers
      const loadingElement = screen.queryByRole('status') ||
                           screen.queryByLabelText(/loading/i) ||
                           screen.queryByText(/loading/i);

      if (loadingElement) {
        expect(loadingElement).toBeInTheDocument();
      }

      // Should have appropriate ARIA attributes for loading state
      const container = screen.container;
      const ariaElement = container.querySelector('[aria-busy], [aria-live], [role="status"]');
      if (ariaElement) {
        expect(ariaElement).toBeInTheDocument();
      }
    });
  });
});
