import React from 'react';
import PropTypes from 'prop-types';
import { Nav, Spinner } from 'patternfly-react';
import { noop } from '../../../common/helpers';

import { locationPropType, organizationPropType } from '../LayoutHelper';
import { ANY_ORGANIZATION_TEXT, ANY_LOCATION_TEXT } from '../LayoutConstants';
import NavItem from './NavItem';
import TaxonomyDropdown from './TaxonomyDropdown';

const TaxonomySwitcher = ({
  currentOrganization,
  currentLocation,
  organizations,
  locations,
  isLoading,
  onLocationClick,
  onOrgClick,
}) => (
  <Nav navbar pullLeft className="navbar-iconic">
    <TaxonomyDropdown
      taxonomyType="organization"
      currentTaxonomy={currentOrganization}
      taxonomies={organizations}
      changeTaxonomy={onOrgClick}
    />
    <TaxonomyDropdown
      taxonomyType="location"
      currentTaxonomy={currentLocation}
      taxonomies={locations}
      changeTaxonomy={onLocationClick}
    />
    {isLoading && (
      <NavItem id="vertical-spinner">
        <Spinner size="md" inverse loading />
      </NavItem>
    )}
  </Nav>
);
TaxonomySwitcher.propTypes = {
  onLocationClick: PropTypes.func,
  onOrgClick: PropTypes.func,
  isLoading: PropTypes.bool,
  currentOrganization: PropTypes.string,
  currentLocation: PropTypes.string,
  organizations: PropTypes.arrayOf(organizationPropType).isRequired,
  locations: PropTypes.arrayOf(locationPropType).isRequired,
};
TaxonomySwitcher.defaultProps = {
  isLoading: false,
  currentLocation: ANY_LOCATION_TEXT,
  currentOrganization: ANY_ORGANIZATION_TEXT,
  onLocationClick: noop,
  onOrgClick: noop,
};
export default TaxonomySwitcher;
