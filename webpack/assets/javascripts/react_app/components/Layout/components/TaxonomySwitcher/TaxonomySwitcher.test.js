import TaxonomySwitcher from './TaxonomySwitcher';
import { layoutData } from '../../Layout.fixtures';
import ForemanContext from '../../../../Root/Context/ForemanContext';

import React from 'react';
import { fireEvent, screen, render, act } from '@testing-library/react';
import '@testing-library/jest-dom';
const props = {
  organizations: layoutData.orgs.available_organizations,
  locations: layoutData.locations.available_locations,
  isLoading: true,
};

jest
  .spyOn(ForemanContext, 'useForemanLocation')
  .mockReturnValue({ title: 'london' });
jest
  .spyOn(ForemanContext, 'useForemanOrganization')
  .mockReturnValue({ title: 'org1' });
describe('TaxonomySwitcher', () => {
  it('should switch orgs and locations', async () => {
    render(<TaxonomySwitcher {...props} />);
    expect(screen.getAllByText('london')).toHaveLength(1);
    expect(screen.getAllByText('org1')).toHaveLength(1);
    await act(async () => {
      fireEvent.click(screen.getByText('london'));
    });
    expect(screen.getAllByText('london')).toHaveLength(2);
    expect(screen.getAllByText('norway')).toHaveLength(1);
    expect(screen.getByRole('menuitem', { name: 'norway' })).toHaveAttribute(
      'href',
      '/locations/3-norway/select'
    );

    await act(async () => {
      fireEvent.click(screen.getByText('org1'));
    });
    expect(screen.getAllByText('org1')).toHaveLength(2);
    expect(screen.getAllByText('org2')).toHaveLength(1);
    expect(screen.getByRole('menuitem', { name: 'org2' })).toHaveAttribute(
      'href',
      '/organizations/2-org2/select'
    );
  });
});
