import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import PowerStatus from '../PowerStatus';
import {
  pendingProps,
  errorProps,
  successProps,
  successWithOffProps,
} from '../PowerStatus.fixtures';

describe('PowerStatusInner', () => {
  it('should render power status with spinner', () => {
    render(<PowerStatus {...pendingProps} />);

    expect(screen.getByLabelText('Loading')).toBeInTheDocument();
  });

  it('should render power status with error', () => {
    const { container } = render(<PowerStatus {...errorProps} />);

    expect(screen.getByTitle('some_error')).toBeInTheDocument();
    expect(
      container.querySelector('.host-power-status.na')
    ).toBeInTheDocument();
  });

  it('should render power status when resolved with on', () => {
    const { container } = render(<PowerStatus {...successProps} />);

    expect(screen.getByTitle('some_status_text')).toBeInTheDocument();
    expect(
      container.querySelector('.host-power-status.on')
    ).toBeInTheDocument();
  });

  it('should render power status when resolved with off', () => {
    const { container } = render(<PowerStatus {...successWithOffProps} />);

    expect(screen.getByTitle('some_status_text')).toBeInTheDocument();
    expect(
      container.querySelector('.host-power-status.off')
    ).toBeInTheDocument();
  });
});
