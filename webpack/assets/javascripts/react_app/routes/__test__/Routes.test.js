import React from 'react';
import { Router } from 'react-router-dom';
import { createMemoryHistory } from 'history';
import { act, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import AppSwitcher from '../';
import { rtlHelpers } from '../../common/rtlTestHelpers';
import { visit } from '../../common/helpers';

const { renderWithStore } = rtlHelpers;

const renderAppSwitcher = (initialPath, children = null) => {
  const history = createMemoryHistory({ initialEntries: [initialPath] });

  return {
    history,
    ...renderWithStore(
      <Router history={history}>
        <AppSwitcher>{children}</AppSwitcher>
      </Router>
    ),
  };
};

describe('Routes', () => {
  afterEach(() => {
    visit.mockClear();
  });

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

  it('uses fallbackRoute to visit the current url for an unmatched path', () => {
    const { history } = renderAppSwitcher(
      '/upgrade',
      <p>Router extra content</p>
    );

    expect(
      screen.getByRole('heading', { name: 'Foreman upgrade' })
    ).toBeInTheDocument();
    expect(visit).not.toHaveBeenCalled();

    act(() => {
      history.push('/not-a-foreman-route');
    });

    expect(
      screen.queryByRole('heading', { name: 'Foreman upgrade' })
    ).not.toBeInTheDocument();
    expect(screen.getByText('Router extra content')).toBeInTheDocument();
    expect(visit).toHaveBeenCalledWith(window.location.href);
  });
});
