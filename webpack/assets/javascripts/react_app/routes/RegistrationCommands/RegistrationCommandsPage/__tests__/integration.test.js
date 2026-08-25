import React from 'react';
import { screen, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import { rtlHelpers } from '../../../../common/rtlTestHelpers';
import API from '../../../../redux/API/API';
import RegistrationCommandsPage from '../index';
import { formData } from './fixtures';

const { renderWithStore } = rtlHelpers;

const generatedCommand =
  "curl -sS 'https://foreman.example.com/register' | bash";

const renderPage = () =>
  renderWithStore(
    <MemoryRouter>
      <RegistrationCommandsPage />
    </MemoryRouter>
  );

const getOrganizationSelect = () =>
  screen.getByRole('combobox', { name: /Organization/i });

const getLocationSelect = () =>
  screen.getByRole('combobox', { name: /Location/i });

const currentOrganization = formData.organizations.find(
  organization => organization.id === 1
);
const otherOrganization = formData.organizations.find(
  organization => organization.id === 3
);
const currentLocation = formData.locations.find(location => location.id === 2);
const otherLocation = formData.locations.find(location => location.id === 4);

const waitForFormData = async () => {
  const organizationSelect = getOrganizationSelect();

  await within(organizationSelect).findByRole('option', {
    name: currentOrganization.name,
  });
};

describe('RegistrationCommandsPage', () => {
  beforeEach(() => {
    API.get.mockResolvedValue({
      data: {
        organizations: formData.organizations,
        locations: formData.locations,
      },
    });
    API.post.mockResolvedValue({
      data: { command: generatedCommand },
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('shows only the current organization and location as options', async () => {
    renderPage();
    await waitForFormData();

    expect(
      within(getOrganizationSelect()).getByRole('option', {
        name: 'Not specified',
      })
    ).toBeInTheDocument();
    expect(
      within(getOrganizationSelect()).getByRole('option', {
        name: currentOrganization.name,
      })
    ).toBeInTheDocument();
    expect(
      within(getOrganizationSelect()).queryByRole('option', {
        name: otherOrganization.name,
      })
    ).not.toBeInTheDocument();

    expect(
      within(getLocationSelect()).getByRole('option', { name: 'Not specified' })
    ).toBeInTheDocument();
    expect(
      within(getLocationSelect()).getByRole('option', {
        name: currentLocation.name,
      })
    ).toBeInTheDocument();
    expect(
      within(getLocationSelect()).queryByRole('option', {
        name: otherLocation.name,
      })
    ).not.toBeInTheDocument();
  });

  it('generates a registration command', async () => {
    renderPage();
    await waitForFormData();

    const generateButton = screen.getByRole('button', { name: 'Generate' });

    expect(generateButton).toBeEnabled();
    expect(screen.queryByText('Registration command')).not.toBeInTheDocument();
    expect(screen.queryByText(generatedCommand)).not.toBeInTheDocument();

    userEvent.click(generateButton);

    expect(await screen.findByText('Registration command')).toBeInTheDocument();
    expect(screen.getByText(generatedCommand)).toBeInTheDocument();
    expect(API.post).toHaveBeenCalledWith(
      '/hosts/register',
      expect.objectContaining({
        organizationId: currentOrganization.id,
        locationId: currentLocation.id,
        downloadUtility: 'curl',
        insecure: false,
        jwtExpiration: 4,
      }),
      expect.any(Object)
    );
  });
});
