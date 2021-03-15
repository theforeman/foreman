import React from 'react';
import { testComponentSnapshotsWithFixtures, shallow } from '@theforeman/test';
import TaxonomyDropdown from './TaxonomyDropdown';
import { hasTaxonomiesMock } from '../../Layout.fixtures';

const props = {
  taxonomyType: 'organization',
  id: 'organization-dropdown',
  currentTaxonomy: hasTaxonomiesMock.currentOrganization,
  taxonomies: hasTaxonomiesMock.data.orgs.available_organizations,
  anyTaxonomyText: 'Any Organization',
  manageTaxonomyText: 'Manage Organizations',
  anyTaxonomyURL: '/organizations/clear',
  manageTaxonomyURL: '/organizations',
  isOpen: true,
};

const fixtures = {
  rendering: { ...props },
};

describe('TaxonomyDropdown', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(TaxonomyDropdown, fixtures));

  it('Search items', () => {
    const wrapper = shallow(<TaxonomyDropdown {...props} />);
    const child = () => wrapper.children();
    expect(child()).toMatchSnapshot();
    wrapper.props().onSearchInputChange('', { target: { value: 'org1' } });
    wrapper.props().onSearchButtonClick();
    wrapper.update();
    expect(child()).toMatchSnapshot();
  });
});
