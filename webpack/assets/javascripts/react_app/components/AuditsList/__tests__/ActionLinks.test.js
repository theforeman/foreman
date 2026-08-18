import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import ActionLinks from '../ActionLinks';
import { actionsList } from './AuditsList.fixtures';

describe('ActionLinks', () => {
  it('renders action links', () => {
    render(<ActionLinks allowedActions={actionsList} />);

    const link = screen.getByRole('link', { name: 'Host details' });

    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', '/hosts/foo.example.com');
  });

  it('renders disabled action link', () => {
    render(
      <ActionLinks
        allowedActions={[
          { url: '#', title: 'Disabled action', disabled: true },
        ]}
      />
    );

    expect(
      screen.getByRole('link', { name: 'Disabled action' })
    ).toHaveAttribute('aria-disabled', 'true');
  });

  it('prefers name over title for link text', () => {
    render(
      <ActionLinks
        allowedActions={[
          { url: '/example', name: 'Custom name', title: 'Title text' },
        ]}
      />
    );

    expect(
      screen.getByRole('link', { name: 'Custom name' })
    ).toBeInTheDocument();
    expect(
      screen.queryByRole('link', { name: 'Title text' })
    ).not.toBeInTheDocument();
  });
});
