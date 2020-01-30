import React from 'react';
import { shallow } from '@theforeman/test';

import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import TaxonomyDropdown from './TaxonomyDropdown';
import { hasTaxonomiesMock } from '../Layout.fixtures';

const props = {
  taxonomyType: 'Organization',
  id: 'organization-dropdown',
  currentTaxonomy: hasTaxonomiesMock.currentOrganization,
  taxonomies: hasTaxonomiesMock.data.orgs.available_organizations,
  anyTaxonomyText: 'Any Organization',
  manageTaxonomyText: 'Manage Organizations',
  anyTaxonomyURL: '/organizations/clear',
  manageTaxonomyURL: '/organizations',
};

const propsSearch = {
  ...props,
  taxonomies: hasTaxonomiesMock.data.orgs.many_organizations,
};

const fixtures = {
  'render TaxonomyDropdown': { ...props },
  'render TaxonomyDropdownWithSearch': { ...propsSearch },
};

describe('TaxonomyDropdown', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(TaxonomyDropdown, fixtures));

  describe('simulate onClick', () => {
    const changeTaxonomy = jest.fn();

    const wrapper = shallow(
      <TaxonomyDropdown {...props} changeTaxonomy={changeTaxonomy} />
    );
    wrapper
      .find('.organization_menuitem')
      .at(0)
      .simulate('click');
    wrapper.find('.organizations_clear').simulate('click');
    expect(changeTaxonomy).toHaveBeenCalledTimes(2);
  });

  it('Search items', () => {
    const wrapper = shallow(<TaxonomyDropdown {...propsSearch} />);
    const searchInput = wrapper.find('input.taxonomy_search');

    expect(searchInput.exists()).toBeTruthy();

    searchInput.simulate('change', { target: { value: 'org7' } });
    expect(wrapper.find('a.organization_menuitem')).toHaveLength(1);

    searchInput.simulate('change', { target: { value: '' } });
    expect(wrapper.find('a.organization_menuitem')).toHaveLength(7);
  });
});
