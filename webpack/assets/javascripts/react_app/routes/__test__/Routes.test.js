import React from 'react';
import { MemoryRouter } from 'react-router-dom';
import { screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import AppSwitcher from '../';
import { rtlHelpers } from '../../common/rtlTestHelpers';

const { renderWithStore } = rtlHelpers;

const renderAppSwitcher = (initialPath, children = null) =>
  renderWithStore(
    <MemoryRouter initialEntries={[initialPath]}>
      <AppSwitcher>{children}</AppSwitcher>
    </MemoryRouter>
  );

describe('Routes', () => {
  it('renders children alongside the matched route', () => {
    renderAppSwitcher('/upgrade', <p>Router extra content</p>);

    expect(
      screen.getByRole('heading', { name: 'Foreman upgrade' })
    ).toBeInTheDocument();
    expect(screen.getByText('Router extra content')).toBeInTheDocument();
  });

  it('renders the empty page at /page-not-found', () => {
    renderAppSwitcher('/page-not-found');

    expect(
      screen.getByRole('heading', { name: 'Resource not found' })
    ).toBeInTheDocument();
  });

  it('does not render a core page for an unmatched path', () => {
    renderAppSwitcher('/not-a-foreman-route', <p>Router extra content</p>);

    expect(
      screen.queryByRole('heading', { name: 'Foreman upgrade' })
    ).not.toBeInTheDocument();
    expect(screen.getByText('Router extra content')).toBeInTheDocument();
  });
});
