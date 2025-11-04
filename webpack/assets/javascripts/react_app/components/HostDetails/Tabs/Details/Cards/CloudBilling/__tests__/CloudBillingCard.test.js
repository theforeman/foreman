import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import CloudBillingCard from '../index';
import { CardExpansionContext } from '../../../../../CardExpansionContext';

jest.mock('../../../../../../../common/I18n', () => ({
  translate: jest.fn(text => text),
}));

// Helper to wrap component with required context
const renderWithContext = (component) => {
  const mockContextValue = {
    cardExpandStates: { 'Cloud billing details': true }, // Expand the card
    dispatch: jest.fn(),
    registerCard: jest.fn(),
  };

  return render(
    <CardExpansionContext.Provider value={mockContextValue}>
      {component}
    </CardExpansionContext.Provider>
  );
};
import {
  hostDetailsAws,
  hostDetailsGcp,
  hostDetailsAzure,
  hostDetailsNonCloud,
  hostDetailsNoProvider,
  hostDetailsWithoutProvider,
  hostDetailsAwsWithFacts,
  hostDetailsGcpWithFacts,
  hostDetailsAzureWithFacts,
} from './CloudBilling.fixtures';

describe('CloudBillingCard', () => {
  const baseProps = {};

  describe('Required Props Validation', () => {
    it('does not render when reported_data is missing', () => {
      const { container } = renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={{}} // No reported_data
        />
      );

      expect(container.firstChild).toBeNull();
    });

    it('does not render when reported_data is empty', () => {
      const { container } = renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={{ reported_data: {} }}
        />
      );

      expect(container.firstChild).toBeNull();
    });
  });

  describe('Provider Detection', () => {
    it('renders for AWS/EC2 provider with billing data', () => {
      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostDetailsAwsWithFacts}
        />
      );

      expect(screen.getByText('Cloud billing details')).toBeInTheDocument();
      expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
    });

    it('renders for GCP/gce provider with billing data', () => {
      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostDetailsGcpWithFacts}
        />
      );

      expect(screen.getByText('Cloud billing details')).toBeInTheDocument();
      expect(screen.getByText('GCP License Code')).toBeInTheDocument();
    });

    it('renders for Azure/azurerm provider with billing data', () => {
      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostDetailsAzureWithFacts}
        />
      );

      expect(screen.getByText('Cloud billing details')).toBeInTheDocument();
      expect(screen.getByText('Azure Subscription ID')).toBeInTheDocument();
    });

    it('does not render for non-cloud providers', () => {
      const { container} = renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostDetailsNonCloud}
        />
      );

      expect(container.firstChild).toBeNull();
    });

    it('detects AWS provider from reported_data when compute_resource_provider is not present', () => {
      const hostWithoutProvider = {
        reported_data: hostDetailsAwsWithFacts.reported_data,
      };

      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostWithoutProvider}
        />
      );

      expect(screen.getByText('Cloud billing details')).toBeInTheDocument();
      expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
    });

    it('detects GCP provider from reported_data when compute_resource_provider is not present', () => {
      const hostWithoutProvider = {
        reported_data: hostDetailsGcpWithFacts.reported_data,
      };

      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostWithoutProvider}
        />
      );

      expect(screen.getByText('Cloud billing details')).toBeInTheDocument();
      expect(screen.getByText('GCP Project ID')).toBeInTheDocument();
    });

    it('detects Azure provider from reported_data when compute_resource_provider is not present', () => {
      const hostWithoutProvider = {
        reported_data: hostDetailsAzureWithFacts.reported_data,
      };

      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostWithoutProvider}
        />
      );

      expect(screen.getByText('Cloud billing details')).toBeInTheDocument();
      expect(screen.getByText('Azure Subscription ID')).toBeInTheDocument();
    });
  });


  describe('Billing Data Detection', () => {
    it('does not render when no billing data is available for AWS', () => {
      const hostWithoutBillingData = {
        compute_resource_provider: 'ec2',
        reported_data: {},
      };

      const { container } = renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostWithoutBillingData}
        />
      );

      expect(container.firstChild).toBeNull();
    });

    it('does not render when no billing data is available for GCP', () => {
      const hostWithoutBillingData = {
        compute_resource_provider: 'gce',
        reported_data: {},
      };

      const { container } = renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostWithoutBillingData}
        />
      );

      expect(container.firstChild).toBeNull();
    });

    it('does not render when no billing data is available for Azure', () => {
      const hostWithoutBillingData = {
        compute_resource_provider: 'azurerm',
        reported_data: {},
      };

      const { container } = renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostWithoutBillingData}
        />
      );

      expect(container.firstChild).toBeNull();
    });

    it('renders when any AWS billing field is present in reported_data', () => {
      const hostWithMinimalData = {
        compute_resource_provider: 'ec2',
        reported_data: { aws_account_id: '123456789' },
      };

      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostWithMinimalData}
        />
      );

      expect(screen.getByText('Cloud billing details')).toBeInTheDocument();
    });

    it('renders when any GCP billing field is present in reported_data', () => {
      const hostWithMinimalData = {
        compute_resource_provider: 'gce',
        reported_data: { gcp_license_codes: '12345' },
      };

      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostWithMinimalData}
        />
      );

      expect(screen.getByText('Cloud billing details')).toBeInTheDocument();
    });

    it('renders when any Azure billing field is present in reported_data', () => {
      const hostWithMinimalData = {
        compute_resource_provider: 'azurerm',
        reported_data: { azure_subscription_id: 'sub-123' },
      };

      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostWithMinimalData}
        />
      );

      expect(screen.getByText('Cloud billing details')).toBeInTheDocument();
    });
  });


  describe('Card Rendering', () => {
    it('renders card with expandable layout', () => {
      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostDetailsAwsWithFacts}
        />
      );

      // Card should render with header and content
      expect(screen.getByText('Cloud billing details')).toBeInTheDocument();
      expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
    });

    it('displays correct header text', () => {
      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostDetailsAwsWithFacts}
        />
      );

      expect(screen.getByText('Cloud billing details')).toBeInTheDocument();
    });
  });

  describe('Component Selection', () => {
    it('renders BillingAws component for EC2 provider', () => {
      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostDetailsAwsWithFacts}
        />
      );

      // Check for AWS-specific labels
      expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
      expect(screen.queryByText('GCP Instance ID')).not.toBeInTheDocument();
      expect(screen.queryByText('Azure Subscription ID')).not.toBeInTheDocument();
    });

    it('renders BillingGcp component for gce provider', () => {
      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostDetailsGcpWithFacts}
        />
      );

      // Check for GCP-specific labels
      expect(screen.getByText('GCP License Code')).toBeInTheDocument();
      expect(screen.queryByText('AWS Account ID')).not.toBeInTheDocument();
      expect(screen.queryByText('Azure Subscription ID')).not.toBeInTheDocument();
    });

    it('renders BillingAzure component for azurerm provider', () => {
      renderWithContext(
        <CloudBillingCard
          {...baseProps}
          hostDetails={hostDetailsAzureWithFacts}
        />
      );

      // Check for Azure-specific labels
      expect(screen.getByText('Azure Subscription ID')).toBeInTheDocument();
      expect(screen.queryByText('AWS Account ID')).not.toBeInTheDocument();
      expect(screen.queryByText('GCP Instance ID')).not.toBeInTheDocument();
    });
  });
});
