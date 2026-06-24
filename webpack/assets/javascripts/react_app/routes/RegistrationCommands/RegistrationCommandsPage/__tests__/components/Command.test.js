import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import Command from '../../components/Command';
import { STATUS } from '../../../../../constants';
import { commandComponentProps } from '../fixtures';

describe('RegistrationCommandsPage - Command', () => {
  it('renders the registration command when API status is resolved', () => {
    render(<Command {...commandComponentProps} />);

    expect(screen.getByText('Registration command')).toBeInTheDocument();
    expect(screen.getByText('command')).toBeInTheDocument();
  });

  it('renders an error alert when API status is error', () => {
    render(<Command apiStatus={STATUS.ERROR} command="" />);

    expect(
      screen.getByRole('heading', {
        name: /There was an error while generating the command/i,
      })
    ).toBeInTheDocument();
  });

  it('renders an empty form group while command is pending', () => {
    render(<Command apiStatus={STATUS.PENDING} command="" />);

    expect(screen.queryByText('Registration command')).not.toBeInTheDocument();
    expect(
      screen.queryByRole('heading', {
        name: /There was an error while generating the command/i,
      })
    ).not.toBeInTheDocument();
  });
});
