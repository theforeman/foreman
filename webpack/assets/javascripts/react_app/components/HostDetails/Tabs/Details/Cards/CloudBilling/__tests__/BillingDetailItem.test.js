import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import BillingDetailItem from '../BillingDetailItem';

jest.mock('../../../../../../../common/I18n', () => ({
  translate: jest.fn(text => text),
}));

describe('BillingDetailItem', () => {
  it('renders label and value when value is provided', () => {
    render(
      <BillingDetailItem
        label="Test Label"
        value="Test Value"
      />
    );

    expect(screen.getByText('Test Label')).toBeInTheDocument();
    expect(screen.getByText('Test Value')).toBeInTheDocument();
  });

  it('renders numeric values correctly', () => {
    render(
      <BillingDetailItem
        label="Numeric Field"
        value={123456789}
      />
    );

    expect(screen.getByText('Numeric Field')).toBeInTheDocument();
    expect(screen.getByText('123456789')).toBeInTheDocument();
  });

  it('does not render when value is undefined', () => {
    const { container } = render(
      <BillingDetailItem
        label="Test Label"
        value={undefined}
      />
    );

    expect(container.firstChild).toBeNull();
  });

  it('does not render when value is null', () => {
    const { container } = render(
      <BillingDetailItem
        label="Test Label"
        value={null}
      />
    );

    expect(container.firstChild).toBeNull();
  });

  it('does not render when value is empty string', () => {
    const { container } = render(
      <BillingDetailItem
        label="Test Label"
        value=""
      />
    );

    expect(container.firstChild).toBeNull();
  });

  it('renders with proper structure', () => {
    render(
      <BillingDetailItem
        label="Test Label"
        value="Test Value"
      />
    );

    // Check that both label and value are in the document
    expect(screen.getByText('Test Label')).toBeInTheDocument();
    expect(screen.getByText('Test Value')).toBeInTheDocument();
  });
});
