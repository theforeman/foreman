import React from 'react';
import PropTypes from 'prop-types';
import { Nav, Spinner } from 'patternfly-react';
import { noop } from '../../../common/helpers';

import { locationPropType, organizationPropType } from '../LayoutHelper';
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
  onLocationClick: noop,
  onOrgClick: noop,
  currentLocation: undefined,
  currentOrganization: undefined,
};
export default TaxonomySwitcher;
