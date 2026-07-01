import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import { screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import AuditsPage from '../AuditsPage';
import { auditsPageProps } from '../AuditsPage.fixtures';
import { rtlHelpers } from '../../../../common/rtlTestHelpers';

const { renderWithStoreAndI18n } = rtlHelpers;

const renderAuditsPage = (props = {}) => {
  renderWithStoreAndI18n(
    <Router>
      <AuditsPage {...auditsPageProps} {...props} />
    </Router>
  );
};

const expectAuditsPageReady = () =>
  screen.findByRole('heading', { name: 'Audits', level: 1 });

describe('AuditsPage', () => {
  it('renders audits page', async () => {
    renderAuditsPage();
    await expectAuditsPageReady();

    expect(screen.getByRole('link', { name: /Documentation/i })).toHaveAttribute(
      'href',
      '/links/manual/4.1.4Auditing'
    );
    expect(screen.getByLabelText('Search input')).toBeInTheDocument();
    expect(screen.getByText('host-foo.example.com')).toBeInTheDocument();
  });

  it('renders audits page with no audit rows', async () => {
    renderAuditsPage({
      hasError: false,
      hasData: true,
      audits: [],
      itemCount: 0,
    });
    await expectAuditsPageReady();

    expect(
      screen.getByRole('list', { name: 'Audits data list' })
    ).toBeInTheDocument();
    expect(screen.queryByText('host-foo.example.com')).not.toBeInTheDocument();
  });

  it('renders loading audits page', async () => {
    renderAuditsPage({
      isLoading: true,
      hasData: false,
    });
    await expectAuditsPageReady();

    expect(
      screen.queryByRole('list', { name: 'Audits data list' })
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole('heading', { name: 'Error', level: 5 })
    ).not.toBeInTheDocument();
  });

  it('renders audits page with error when audit data is present', async () => {
    renderAuditsPage({
      hasError: true,
      hasData: true,
      audits: auditsPageProps.audits,
      itemCount: auditsPageProps.itemCount,
      message: { type: 'error', text: 'some-error' },
    });
    await expectAuditsPageReady();

    expect(
      screen.getByRole('heading', { name: 'Error', level: 5 })
    ).toBeInTheDocument();
    expect(screen.getByText('some-error')).toBeInTheDocument();
    expect(
      screen.queryByRole('list', { name: 'Audits data list' })
    ).not.toBeInTheDocument();
    expect(screen.queryByText('host-foo.example.com')).not.toBeInTheDocument();
  });

  it('renders audits page with error when no audit data is present', async () => {
    renderAuditsPage({
      hasError: true,
      hasData: false,
      audits: [],
      itemCount: 0,
      message: { type: 'error', text: 'no audits' },
    });
    await expectAuditsPageReady();

    expect(
      screen.getByRole('heading', { name: 'Error', level: 5 })
    ).toBeInTheDocument();
    expect(screen.getByText('no audits')).toBeInTheDocument();
    expect(
      screen.queryByRole('list', { name: 'Audits data list' })
    ).not.toBeInTheDocument();
  });
});
