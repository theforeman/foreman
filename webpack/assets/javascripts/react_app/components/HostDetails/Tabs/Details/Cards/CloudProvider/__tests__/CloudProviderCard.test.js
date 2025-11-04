import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import CloudProviderCard from '../index';
import { CardExpansionContext } from '../../../../../CardExpansionContext';

// Helper to wrap component with required context
const renderWithContext = (component) => {
  const mockContextValue = {
    cardExpandStates: {
      'AWS details': true,
      'Azure details': true,
      'GCP details': true,
      'Cloud provider details': true,
    }, // Expand the card
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
} from './CloudProvider.fixtures';

describe('CloudProviderCard', () => {
  const baseProps = {};

  describe('Required Props Validation', () => {
    it('does not render when reported_data is missing', () => {
      const { container } = renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={{}} // No reported_data
        />
      );

      expect(container.firstChild).toBeNull();
    });

    it('does not render when reported_data is empty', () => {
      const { container } = renderWithContext(
        <CloudProviderCard
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
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostDetailsAwsWithFacts}
        />
      );

      expect(screen.getByText('AWS details')).toBeInTheDocument();
      expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
    });

    it('renders for GCP/gce provider with billing data', () => {
      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostDetailsGcpWithFacts}
        />
      );

      expect(screen.getByText('GCP details')).toBeInTheDocument();
      expect(screen.getByText('GCP License Code')).toBeInTheDocument();
    });

    it('renders for Azure/azurerm provider with billing data', () => {
      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostDetailsAzureWithFacts}
        />
      );

      expect(screen.getByText('Azure details')).toBeInTheDocument();
      expect(screen.getByText('Azure Subscription ID')).toBeInTheDocument();
    });

    it('does not render for non-cloud providers', () => {
      const { container} = renderWithContext(
        <CloudProviderCard
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
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostWithoutProvider}
        />
      );

      expect(screen.getByText('AWS details')).toBeInTheDocument();
      expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
    });

    it('detects GCP provider from reported_data when compute_resource_provider is not present', () => {
      const hostWithoutProvider = {
        reported_data: hostDetailsGcpWithFacts.reported_data,
      };

      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostWithoutProvider}
        />
      );

      expect(screen.getByText('GCP details')).toBeInTheDocument();
      expect(screen.getByText('GCP Project ID')).toBeInTheDocument();
    });

    it('detects Azure provider from reported_data when compute_resource_provider is not present', () => {
      const hostWithoutProvider = {
        reported_data: hostDetailsAzureWithFacts.reported_data,
      };

      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostWithoutProvider}
        />
      );

      expect(screen.getByText('Azure details')).toBeInTheDocument();
      expect(screen.getByText('Azure Subscription ID')).toBeInTheDocument();
    });

    it('detects GCP provider when neither cloud_provider nor compute_resource_provider is set', () => {
      const hostWithOnlyBillingData = {
        compute_resource_provider: null,
        reported_data: {
          gcp_license_codes: '7883559014960410759',
          gcp_project_id: 'my-gcp-project',
        },
      };

      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostWithOnlyBillingData}
        />
      );

      expect(screen.getByText('GCP details')).toBeInTheDocument();
      expect(screen.getByText('GCP License Code')).toBeInTheDocument();
    });

    it('detects AWS provider when neither cloud_provider nor compute_resource_provider is set', () => {
      const hostWithOnlyBillingData = {
        compute_resource_provider: null,
        reported_data: {
          aws_account_id: '123456789',
          aws_region: 'us-east-1',
        },
      };

      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostWithOnlyBillingData}
        />
      );

      expect(screen.getByText('AWS details')).toBeInTheDocument();
      expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
    });

    it('detects Azure provider when neither cloud_provider nor compute_resource_provider is set', () => {
      const hostWithOnlyBillingData = {
        compute_resource_provider: null,
        reported_data: {
          azure_subscription_id: 'sub-123',
          azure_offer: 'RHEL',
        },
      };

      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostWithOnlyBillingData}
        />
      );

      expect(screen.getByText('Azure details')).toBeInTheDocument();
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
        <CloudProviderCard
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
        <CloudProviderCard
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
        <CloudProviderCard
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
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostWithMinimalData}
        />
      );

      expect(screen.getByText('AWS details')).toBeInTheDocument();
    });

    it('renders when any GCP billing field is present in reported_data', () => {
      const hostWithMinimalData = {
        compute_resource_provider: 'gce',
        reported_data: { gcp_license_codes: '12345' },
      };

      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostWithMinimalData}
        />
      );

      expect(screen.getByText('GCP details')).toBeInTheDocument();
    });

    it('renders when any Azure billing field is present in reported_data', () => {
      const hostWithMinimalData = {
        compute_resource_provider: 'azurerm',
        reported_data: { azure_subscription_id: 'sub-123' },
      };

      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostWithMinimalData}
        />
      );

      expect(screen.getByText('Azure details')).toBeInTheDocument();
    });
  });


  describe('Card Rendering', () => {
    it('renders card with expandable layout', () => {
      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostDetailsAwsWithFacts}
        />
      );

      // Card should render with header and content
      expect(screen.getByText('AWS details')).toBeInTheDocument();
      expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
    });

    it('displays correct header text', () => {
      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostDetailsAwsWithFacts}
        />
      );

      expect(screen.getByText('AWS details')).toBeInTheDocument();
    });
  });

  describe('Component Selection', () => {
    it('renders CloudProviderAws component for EC2 provider', () => {
      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostDetailsAwsWithFacts}
        />
      );

      // Check for AWS-specific labels
      expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
      expect(screen.queryByText('GCP Instance ID')).not.toBeInTheDocument();
      expect(screen.queryByText('Azure Subscription ID')).not.toBeInTheDocument();
    });

    it('renders CloudProviderGcp component for gce provider', () => {
      renderWithContext(
        <CloudProviderCard
          {...baseProps}
          hostDetails={hostDetailsGcpWithFacts}
        />
      );

      // Check for GCP-specific labels
      expect(screen.getByText('GCP License Code')).toBeInTheDocument();
      expect(screen.queryByText('AWS Account ID')).not.toBeInTheDocument();
      expect(screen.queryByText('Azure Subscription ID')).not.toBeInTheDocument();
    });

    it('renders CloudProviderAzure component for azurerm provider', () => {
      renderWithContext(
        <CloudProviderCard
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
