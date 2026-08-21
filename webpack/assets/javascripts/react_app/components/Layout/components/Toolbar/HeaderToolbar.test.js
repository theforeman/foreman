import React from 'react';
import { screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import HeaderToolbar from './HeaderToolbar';
import { layoutData } from '../../Layout.fixtures';
import ForemanContext from '../../../../Root/Context/ForemanContext';
import { rtlHelpers } from '../../../../common/rtlTestHelpers';

const { renderWithStoreAndI18n } = rtlHelpers;

jest
  .spyOn(ForemanContext, 'useForemanLocation')
  .mockReturnValue({ title: 'london' });
jest
  .spyOn(ForemanContext, 'useForemanOrganization')
  .mockReturnValue({ title: 'org1' });

const defaultProps = {
  locations: layoutData.locations,
  orgs: layoutData.orgs,
  notification_url: layoutData.notification_url,
  user: layoutData.user,
  stop_impersonation_url: layoutData.stop_impersonation_url,
  isLoading: false,
};

const renderHeaderToolbar = (props = {}) =>
  renderWithStoreAndI18n(<HeaderToolbar {...defaultProps} {...props} />);

describe('HeaderToolbar', () => {
  it('renders taxonomy switcher, notifications, impersonation, and user menu', async () => {
    renderHeaderToolbar();

    expect(await screen.findByText('org1')).toBeInTheDocument();
    expect(screen.getByText('london')).toBeInTheDocument();
    expect(screen.getByText('Admin User')).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: 'Notifications' })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: 'Stop impersonation' })
    ).toBeInTheDocument();
  });

  it('does not render impersonation icon when user is not impersonated', async () => {
    renderHeaderToolbar({
      user: { ...layoutData.user, impersonated_by: false },
    });

    expect(await screen.findByText('Admin User')).toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: 'Stop impersonation' })
    ).not.toBeInTheDocument();
  });
});
