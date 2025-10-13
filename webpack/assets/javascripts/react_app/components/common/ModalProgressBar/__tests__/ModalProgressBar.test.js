import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import ModalProgressBar from '../ModalProgressBar';

describe('ModalProgressBar', () => {
  const defaultProps = {
    show: true,
    title: 'Refresh Manifest',
    progress: 9,
  };

  it('should render modal when show is true', () => {
    render(<ModalProgressBar {...defaultProps} />);

    const modal = screen.getByRole('dialog');
    expect(modal).toBeInTheDocument();
    expect(modal).toHaveAttribute('id', 'modal-progress-bar');
  });

  it('should not render modal when show is false', () => {
    render(<ModalProgressBar {...defaultProps} show={false} />);

    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('should display the title', () => {
    render(<ModalProgressBar {...defaultProps} />);

    expect(screen.getByText('Refresh Manifest')).toBeInTheDocument();
  });

  it('should display progress with percentage label', () => {
    render(<ModalProgressBar {...defaultProps} />);

    expect(screen.getByText('9% Complete')).toBeInTheDocument();
  });

  it('should render with custom container', () => {
    const customContainer = document.createElement('div');
    document.body.appendChild(customContainer);

    render(
      <ModalProgressBar {...defaultProps} container={customContainer} />
    );

    const modal = screen.getByRole('dialog');
    expect(modal).toBeInTheDocument();

    document.body.removeChild(customContainer);
    expect(modal).not.toBeInTheDocument();
  });
});
