import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import BillingAws from '../BillingAws';
import {
  awsBillingDataComplete,
  awsBillingDataPartial,
  awsBillingDataMinimal,
} from './CloudBilling.fixtures';

jest.mock('../../../../../../../common/I18n', () => ({
  translate: jest.fn(text => text),
}));

describe('BillingAws', () => {
  it('renders all AWS billing fields when complete data is provided', () => {
    render(<BillingAws data={awsBillingDataComplete} />);

    // Check all labels are present
    expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
    expect(screen.getByText('AWS Billing Product')).toBeInTheDocument();
    expect(screen.getByText('AWS Instance ID')).toBeInTheDocument();
    expect(screen.getByText('AWS Instance Type')).toBeInTheDocument();
    expect(screen.getByText('AWS Marketplace Product')).toBeInTheDocument();
    expect(screen.getByText('AWS Region')).toBeInTheDocument();

    // Check all values are present
    expect(screen.getByText('340706125509')).toBeInTheDocument();
    expect(screen.getByText('bp-6fa54006')).toBeInTheDocument();
    expect(screen.getByText('i-07283719ca51ec39e')).toBeInTheDocument();
    expect(screen.getByText('t3.micro')).toBeInTheDocument();
    expect(screen.getByText('marketplace-code-123')).toBeInTheDocument();
    expect(screen.getByText('us-east-2')).toBeInTheDocument();
  });

  it('only renders fields with values when partial data is provided', () => {
    render(<BillingAws data={awsBillingDataPartial} />);

    // Should render these fields
    expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
    expect(screen.getByText('AWS Instance Type')).toBeInTheDocument();
    expect(screen.getByText('AWS Region')).toBeInTheDocument();

    // Should not render these fields (no data)
    expect(screen.queryByText('AWS Billing Product')).not.toBeInTheDocument();
    expect(screen.queryByText('AWS Instance ID')).not.toBeInTheDocument();
    expect(screen.queryByText('AWS Marketplace Product')).not.toBeInTheDocument();
  });

  it('renders minimal data correctly', () => {
    render(<BillingAws data={awsBillingDataMinimal} />);

    // Should render only account ID
    expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
    expect(screen.getByText('340706125509')).toBeInTheDocument();

    // Should not render other fields
    expect(screen.queryByText('AWS Billing Product')).not.toBeInTheDocument();
    expect(screen.queryByText('AWS Instance ID')).not.toBeInTheDocument();
    expect(screen.queryByText('AWS Instance Type')).not.toBeInTheDocument();
    expect(screen.queryByText('AWS Marketplace Product')).not.toBeInTheDocument();
    expect(screen.queryByText('AWS Region')).not.toBeInTheDocument();
  });

  it('renders DescriptionList container even with no data', () => {
    const { container } = render(<BillingAws data={{}} />);

    // Component renders but has no visible content
    expect(container.firstChild).not.toBeNull();
  });

  it('renders nothing when data is null', () => {
    render(<BillingAws data={null} />);

    // No AWS fields should be visible
    expect(screen.queryByText('AWS Account ID')).not.toBeInTheDocument();
    expect(screen.queryByText('AWS Instance Type')).not.toBeInTheDocument();
  });

  it('renders nothing when data is undefined', () => {
    render(<BillingAws data={undefined} />);

    // No AWS fields should be visible
    expect(screen.queryByText('AWS Account ID')).not.toBeInTheDocument();
    expect(screen.queryByText('AWS Instance Type')).not.toBeInTheDocument();
  });

  it('renders all fields in compact layout', () => {
    render(<BillingAws data={awsBillingDataComplete} />);

    // Verify all expected fields are rendered
    expect(screen.getByText('AWS Account ID')).toBeInTheDocument();
    expect(screen.getByText('AWS Region')).toBeInTheDocument();
    expect(screen.getByText('AWS Instance Type')).toBeInTheDocument();
  });

  it('handles camelCase conversion from snake_case', () => {
    const snakeCaseData = {
      aws_account_id: '123456789',
      aws_instance_type: 't2.micro',
    };

    render(<BillingAws data={snakeCaseData} />);

    // propsToCamelCase should convert snake_case to camelCase
    expect(screen.getByText('123456789')).toBeInTheDocument();
    expect(screen.getByText('t2.micro')).toBeInTheDocument();
  });
});
