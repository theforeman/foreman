import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import Actions from './Actions';

describe('actions', () => {
  it('should include a cancel / submit buttons', () => {
    render(<Actions />);

    expect(
      screen.getByRole('button', { name: /submit/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: /cancel/i })
    ).toBeInTheDocument();
  });

  it('should show disabled submit button', () => {
    render(<Actions disabled />);

    expect(
      screen.getByRole('button', { name: /submit/i })
    ).toBeDisabled();
    expect(
      screen.getByRole('button', { name: /cancel/i })
    ).not.toBeDisabled();
  });

  it('should show a spinner when submitting', () => {
    render(<Actions submitting />);

    expect(
      screen.getByRole('button', { name: /submit/i })
    ).toBeDisabled();
    expect(
      screen.getByRole('button', { name: /cancel/i })
    ).toBeDisabled();
    expect(screen.getByLabelText('Loading')).toBeInTheDocument();
  });
});
