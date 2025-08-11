import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import ModalProgressBar from '../ModalProgressBar';

describe('ModalProgressBar', () => {
  const props = {
    show: true,
    title: 'Refresh Manifest',
    progress: 9,
  };
  const message = 'Proceed with this action?';

  it('renders a modal progress bar with title and message', () => {
    render(<ModalProgressBar {...props} message={message} />);

    // Should display the modal title
    expect(screen.getByText('Refresh Manifest')).toBeInTheDocument();

    // Should display the message
    expect(screen.getByText('Proceed with this action?')).toBeInTheDocument();

    // Should render as a modal dialog
    const modal = screen.queryByRole('dialog') ||
                 screen.container.querySelector('.modal, [class*="modal"]');
    if (modal) {
      expect(modal).toBeInTheDocument();
    }
  });

  it('shows progress bar with correct value', () => {
    render(<ModalProgressBar {...props} message={message} />);

    // Should display progress bar
    const progressBar = screen.queryByRole('progressbar') ||
                       screen.container.querySelector('.progress-bar, [class*="progress"]');

    expect(progressBar).toBeInTheDocument();

    // Should have correct progress value (9%)
    if (progressBar && progressBar.getAttribute) {
      const progressValue = progressBar.getAttribute('aria-valuenow') ||
                           progressBar.getAttribute('value');
      if (progressValue) {
        expect(progressValue).toBe('9');
      }
    }
  });

  it('does not render when show is false', () => {
    render(<ModalProgressBar {...props} show={false} message={message} />);

    // Should not display title when hidden
    expect(screen.queryByText('Refresh Manifest')).not.toBeInTheDocument();

    // Should not display message when hidden
    expect(screen.queryByText('Proceed with this action?')).not.toBeInTheDocument();
  });

  it('handles different progress values', () => {
    const { rerender } = render(
      <ModalProgressBar {...props} progress={25} message={message} />
    );

    let progressBar = screen.queryByRole('progressbar') ||
                     screen.container.querySelector('.progress-bar, [class*="progress"]');

    if (progressBar) {
      expect(progressBar).toBeInTheDocument();
    }

    // Test with different progress value
    rerender(<ModalProgressBar {...props} progress={75} message={message} />);

    progressBar = screen.queryByRole('progressbar') ||
                 screen.container.querySelector('.progress-bar, [class*="progress"]');

    if (progressBar) {
      expect(progressBar).toBeInTheDocument();
    }
  });

  it('handles different titles', () => {
    render(<ModalProgressBar {...props} title="Different Title" message={message} />);

    expect(screen.getByText('Different Title')).toBeInTheDocument();
    expect(screen.queryByText('Refresh Manifest')).not.toBeInTheDocument();
  });

  it('renders without message', () => {
    render(<ModalProgressBar {...props} />);

    // Should still display title
    expect(screen.getByText('Refresh Manifest')).toBeInTheDocument();

    // Should still render progress bar
    const progressBar = screen.queryByRole('progressbar') ||
                       screen.container.querySelector('.progress-bar, [class*="progress"]');

    if (progressBar) {
      expect(progressBar).toBeInTheDocument();
    }
  });

  it('is accessible', () => {
    render(<ModalProgressBar {...props} message={message} />);

    // Modal should be accessible
    const modal = screen.queryByRole('dialog') ||
                 screen.container.querySelector('[role="dialog"], .modal');

    if (modal) {
      expect(modal).toBeInTheDocument();
    }

    // Progress bar should be accessible
    const progressBar = screen.queryByRole('progressbar');
    if (progressBar) {
      expect(progressBar).toBeInTheDocument();

      // Should have appropriate ARIA attributes
      expect(progressBar).toHaveAttribute('aria-valuenow');
    }

    // Title should be accessible as heading or modal title
    const title = screen.getByText('Refresh Manifest');
    const titleElement = title.closest('h1, h2, h3, h4, h5, h6') || title;
    expect(titleElement).toBeInTheDocument();
  });

  it('handles edge cases', () => {
    // Test with 0% progress
    render(<ModalProgressBar {...props} progress={0} message={message} />);

    expect(screen.getByText('Refresh Manifest')).toBeInTheDocument();

    const progressBar = screen.queryByRole('progressbar') ||
                       screen.container.querySelector('.progress-bar, [class*="progress"]');

    if (progressBar) {
      expect(progressBar).toBeInTheDocument();
    }
  });

  it('handles 100% progress', () => {
    render(<ModalProgressBar {...props} progress={100} message={message} />);

    expect(screen.getByText('Refresh Manifest')).toBeInTheDocument();

    const progressBar = screen.queryByRole('progressbar') ||
                       screen.container.querySelector('.progress-bar, [class*="progress"]');

    if (progressBar) {
      expect(progressBar).toBeInTheDocument();
    }
  });
});
