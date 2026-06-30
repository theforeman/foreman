import React from 'react';
import { screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import userEvent from '@testing-library/user-event';

import General from '../../components/General';
import { rtlHelpers } from '../../../../../common/rtlTestHelpers';
import { generalComponentProps } from '../fixtures';

const { renderWithStore } = rtlHelpers;

const renderGeneral = (props = {}) => {
  const defaultProps = {
    ...generalComponentProps,
    ...props,
  };

  return renderWithStore(<General {...defaultProps} />);
};

describe('RegistrationCommandsPage - General', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders general form fields', () => {
    renderGeneral();

    expect(screen.getByText('Organization')).toBeInTheDocument();
    expect(screen.getByText('Location')).toBeInTheDocument();
    expect(screen.getByText('Host group')).toBeInTheDocument();
    expect(screen.getByText('Operating system')).toBeInTheDocument();
    expect(screen.getByText('Smart proxy')).toBeInTheDocument();
    expect(screen.getByText('Download utility')).toBeInTheDocument();
    expect(screen.getByRole('checkbox', { name: /insecure/i })).toBeInTheDocument();
  });

  it('disables form controls when loading', () => {
    renderGeneral({ isLoading: true });

    expect(
      screen.getByRole('combobox', { name: /Organization/i })
    ).toBeDisabled();
    expect(screen.getByRole('combobox', { name: /Location/i })).toBeDisabled();
    expect(
      screen.getByRole('combobox', { name: /Host group/i })
    ).toBeDisabled();
    expect(
      screen.getByRole('combobox', { name: /Operating system/i })
    ).toBeDisabled();
    expect(
      screen.getByRole('combobox', { name: /Smart proxy/i })
    ).toBeDisabled();
    expect(
      screen.getByRole('combobox', { name: /Download utility/i })
    ).toBeDisabled();
    expect(screen.getByRole('checkbox', { name: /insecure/i })).toBeDisabled();
  });

  describe('Taxonomies', () => {
    it('renders organization and location options', () => {
      renderGeneral({
        organizations: [{ id: 1, name: 'Default Organization' }],
        locations: [{ id: 2, name: 'Default Location' }],
      });

      expect(screen.getByText('Default Organization')).toBeInTheDocument();
      expect(screen.getByText('Default Location')).toBeInTheDocument();
    });
  });

  describe('HostGroup', () => {
    it('renders host group options', () => {
      renderGeneral({
        hostGroups: [{ id: 3, title: 'test_hg' }],
      });

      expect(screen.getByText('test_hg')).toBeInTheDocument();
    });
  });

  describe('OperatingSystem', () => {
    it('renders operating system options', () => {
      renderGeneral({
        operatingSystems: [{ id: 4, title: 'RHEL 9' }],
      });

      expect(screen.getByText('RHEL 9')).toBeInTheDocument();
    });

    it('shows initial configuration template link', () => {
      renderGeneral({
        operatingSystemId: 4,
        operatingSystems: [{ id: 4, title: 'RHEL 9' }],
        operatingSystemTemplate: {
          name: 'Host init config',
          path: '/templates/1',
        },
      });

      expect(
        screen.getByText('Initial configuration template:')
      ).toBeInTheDocument();
      const templateLink = screen.getByRole('link', {
        name: 'Host init config',
      });

      expect(templateLink).toBeInTheDocument();
      expect(templateLink).toHaveAttribute('href', '/templates/1');
    });
  });

  describe('SmartProxy', () => {
    it('renders smart proxy options and selected URL', () => {
      renderGeneral({
        smartProxyId: '5',
        smartProxies: [
          {
            id: 5,
            name: 'proxy.example.com',
            url: 'https://proxy.example.com',
          },
        ],
      });

      expect(screen.getByText('proxy.example.com')).toBeInTheDocument();
      expect(screen.getByText('https://proxy.example.com')).toBeInTheDocument();
    });
  });

  describe('DownloadUtility', () => {
    it('renders selected download utility value', () => {
      renderGeneral({ downloadUtility: 'wget' });

      expect(
        screen.getByRole('combobox', { name: /download utility/i })
      ).toHaveValue('wget');
    });
  });

  describe('Insecure', () => {
    it('renders checked insecure checkbox', () => {
      renderGeneral({ insecure: true });

      expect(
        screen.getByRole('checkbox', { name: /insecure/i })
      ).toBeChecked();
    });

    it('calls handleInsecure when checkbox is clicked', async () => {
      const handleInsecure = jest.fn();

      renderGeneral({ handleInsecure });

      await userEvent.click(
        screen.getByRole('checkbox', { name: /insecure/i })
      );

      expect(handleInsecure).toHaveBeenCalledWith(true);
    });
  });
});
