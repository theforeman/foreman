import React from 'react';
import { screen, within, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';

import userEvent from '@testing-library/user-event';

import Taxonomies from '../../components/fields/Taxonomies';
import { rtlHelpers } from '../../../../../common/rtlTestHelpers';
import { taxonomiesProps, formData } from '../fixtures';

const { renderWithStore } = rtlHelpers;

const getOrganizationSelect = () =>
  screen.getByRole('combobox', { name: /Organization/i });

const getLocationSelect = () =>
  screen.getByRole('combobox', { name: /Location/i });

const getHelpButtonForSelect = select =>
  within(select.closest('.pf-v5-c-form__group')).getByRole('button');

const renderWithProvider = (props = {}) => {
  const defaultProps = {
    ...taxonomiesProps,
    ...props,
  };

  return renderWithStore(<Taxonomies {...defaultProps} />);
};

describe('RegistrationCommandsPage fields - Taxonomies', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should render organization and location fields', () => {
    renderWithProvider({
      organizationId: 1,
      locationId: 2,
      organizations: formData.organizations,
      locations: formData.locations,
    });

    expect(screen.getByText('Organization')).toBeInTheDocument();
    expect(screen.getByText('Location')).toBeInTheDocument();

    expect(getOrganizationSelect()).toHaveValue('1');
    expect(getLocationSelect()).toHaveValue('2');

    expect(screen.getAllByText('Not specified')).toHaveLength(2);
    expect(screen.getByText('Default Organization')).toBeInTheDocument();
    expect(screen.getByText('ACME')).toBeInTheDocument();
    expect(screen.getByText('Default Location')).toBeInTheDocument();
    expect(screen.getByText('munich')).toBeInTheDocument();
  });

  it('should call handlers when selection changes', () => {
    const handleOrganization = jest.fn();
    const handleLocation = jest.fn();

    renderWithProvider({
      organizations: formData.organizations,
      locations: formData.locations,
      handleOrganization,
      handleLocation,
    });

    userEvent.selectOptions(getOrganizationSelect(), '1');
    userEvent.selectOptions(getLocationSelect(), '2');

    expect(handleOrganization).toHaveBeenCalledWith('1');
    expect(handleLocation).toHaveBeenCalledWith('2');
  });

  it('should call handlers with empty value when not specified is selected', () => {
    const handleOrganization = jest.fn();
    const handleLocation = jest.fn();

    renderWithProvider({
      organizationId: 1,
      locationId: 2,
      organizations: formData.organizations,
      locations: formData.locations,
      handleOrganization,
      handleLocation,
    });

    userEvent.selectOptions(getOrganizationSelect(), '');
    userEvent.selectOptions(getLocationSelect(), '');

    expect(handleOrganization).toHaveBeenCalledWith('');
    expect(handleLocation).toHaveBeenCalledWith('');
  });

  it('should be disabled when loading', () => {
    renderWithProvider({ isLoading: true });

    expect(getOrganizationSelect()).toBeDisabled();
    expect(getLocationSelect()).toBeDisabled();
  });

  it('should show help text in tooltips', async () => {
    renderWithProvider();

    userEvent.click(getHelpButtonForSelect(getOrganizationSelect()));
    await waitFor(() => {
      expect(
        screen.getByText(
          'If no organization is set, the default organization of the user is assumed.'
        )
      ).toBeInTheDocument();
    });

    userEvent.click(getHelpButtonForSelect(getLocationSelect()));
    await waitFor(() => {
      expect(
        screen.getByText(
          'If no location is set, the default location of the user is assumed.'
        )
      ).toBeInTheDocument();
    });
  });
});
