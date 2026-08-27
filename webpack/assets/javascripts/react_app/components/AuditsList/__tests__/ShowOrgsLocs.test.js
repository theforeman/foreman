import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import ShowOrgsLocs from '../ShowOrgsLocs';
import { TaxonomyProps } from './AuditsList.fixtures';

describe('ShowOrgsLocs', () => {
  it('renders organizations and locations', () => {
    render(<ShowOrgsLocs {...TaxonomyProps} />);

    expect(screen.getByText('Affected Organizations')).toBeInTheDocument();
    expect(screen.getByText('Affected Locations')).toBeInTheDocument();

    expect(screen.getByRole('link', { name: 'testOrg' })).toHaveAttribute(
      'href',
      '/organizations/1-testOrg/edit'
    );
    expect(screen.getByRole('link', { name: 'testOrg2' })).toHaveAttribute(
      'aria-disabled',
      'true'
    );
    expect(screen.getByRole('link', { name: 'testLoc' })).toHaveAttribute(
      'href',
      '/locations/1-testLoc/edit'
    );
  });

  it('renders with empty orgs and locs', () => {
    render(<ShowOrgsLocs />);

    expect(screen.getByText('Affected Organizations')).toBeInTheDocument();
    expect(screen.getByText('Affected Locations')).toBeInTheDocument();
    expect(screen.queryByRole('link')).not.toBeInTheDocument();
  });
});
