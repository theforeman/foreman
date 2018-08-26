import React from 'react';
import { shallow } from 'enzyme';

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

const fixtures = {
  'render TaxonomyDropdown': { ...props },
};

describe('TaxonomyDropdown', () => {
  describe('rendering', () => testComponentSnapshotsWithFixtures(TaxonomyDropdown, fixtures));

  describe('simulate onClick', () => {
    const changeTaxonomy = jest.fn();

    const wrapper = shallow(<TaxonomyDropdown {...props} changeTaxonomy={changeTaxonomy} />);
    wrapper.find('.organization_menuitem').at(0).simulate('click');
    wrapper.find('.organizations_clear').simulate('click');
    expect(changeTaxonomy).toHaveBeenCalledTimes(2);
  });
});
