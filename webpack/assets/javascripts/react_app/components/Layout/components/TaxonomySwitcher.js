import React from 'react';
import PropTypes from 'prop-types';
import { Nav, Spinner } from 'patternfly-react';
import { noop } from '../../../common/helpers';

import NavItem from './NavItem';
import TaxonomyDropdown from './TaxonomyDropdown';

const TaxonomySwitcher = ({
  currentOrganization,
  currentLocation,
  organizations,
  locations,
  taxonomiesBool,
  isLoading,
  onLocationClick,
  onOrgClick,
}) => (
  <Nav navbar pullLeft className="navbar-iconic">
    {taxonomiesBool.organizations && (
      <TaxonomyDropdown
        taxonomyType="Organization"
        id="organization-dropdown"
        currentTaxonomy={currentOrganization}
        taxonomies={organizations}
        changeTaxonomy={onOrgClick}
        anyTaxonomyText="Any Organization"
        manageTaxonomyText="Manage Organizations"
        anyTaxonomyURL="/organizations/clear"
        manageTaxonomyURL="/organizations"
      />
    )}
    {taxonomiesBool.locations && (
      <TaxonomyDropdown
        taxonomyType="Location"
        id="location-dropdown"
        currentTaxonomy={currentLocation}
        taxonomies={locations}
        changeTaxonomy={onLocationClick}
        anyTaxonomyText="Any Location"
        manageTaxonomyText="Manage Locations"
        anyTaxonomyURL="/locations/clear"
        manageTaxonomyURL="/locations"
      />
    )}
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
  organizations: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      title: PropTypes.string,
      href: PropTypes.string.isRequired,
    })
  ).isRequired,
  locations: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      title: PropTypes.string,
      href: PropTypes.string.isRequired,
    })
  ).isRequired,
  taxonomiesBool: PropTypes.shape({
    locations: PropTypes.bool.isRequired,
    organizations: PropTypes.bool.isRequired,
  }).isRequired,
};
TaxonomySwitcher.defaultProps = {
  isLoading: false,
  currentLocation: 'Any Location',
  currentOrganization: 'Any Organization',
  onLocationClick: noop,
  onOrgClick: noop,
};
export default TaxonomySwitcher;
