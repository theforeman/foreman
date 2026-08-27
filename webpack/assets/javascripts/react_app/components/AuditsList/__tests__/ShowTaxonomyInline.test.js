import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import ShowTaxonomyInline from '../ShowTaxonomyInline';
import { TaxonomyProps } from './AuditsList.fixtures';

describe('ShowTaxonomyInline', () => {
  it('renders the display label', () => {
    render(
      <ShowTaxonomyInline
        displayLabel="Affected Organizations"
        items={TaxonomyProps.orgs}
      />
    );

    expect(screen.getByText('Affected Organizations')).toBeInTheDocument();
  });

  it('renders a link for each taxonomy item', () => {
    render(<ShowTaxonomyInline items={TaxonomyProps.orgs} />);

    const link = screen.getByRole('link', { name: 'testOrg' });

    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', '/organizations/1-testOrg/edit');
    expect(screen.getByRole('link', { name: 'testOrg2' })).toBeInTheDocument();
  });

  it('renders a disabled taxonomy link', () => {
    render(<ShowTaxonomyInline items={TaxonomyProps.orgs} />);

    expect(screen.getByRole('link', { name: 'testOrg2' })).toHaveAttribute(
      'aria-disabled',
      'true'
    );
  });

  it('renders no links when items are empty', () => {
    render(<ShowTaxonomyInline displayLabel="Affected Organizations" />);

    expect(screen.getByText('Affected Organizations')).toBeInTheDocument();
    expect(screen.queryByRole('link')).not.toBeInTheDocument();
  });
});
