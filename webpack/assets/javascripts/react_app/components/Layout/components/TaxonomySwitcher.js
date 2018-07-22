import React from 'react';
import PropTypes from 'prop-types';
import { Nav, Spinner } from 'patternfly-react';
import NavItem from './NavItem';

const TaxonomySwitcher = ({
  currentOrganization,
  currentLocation,
  organizations,
  locations,
  taxonomiesBool,
  onOrgClick,
  onLocationClick,
  isLoading,
  ...props
}) => (
  <Nav navbar pullLeft className="navbar-iconic" {...props}>
    {taxonomiesBool.organizations &&
    <NavItem className="dropdown org-switcher" id="organization-dropdown">
      <a
        href="#"
        className="dropdown-toggle nav-item-iconic"
        data-toggle="dropdown"
      >
        {currentOrganization}
        <span className="caret" />
      </a>
      <ul className="dropdown-menu">
        <li className="dropdown-header">{__('Organization')}</li>
        <li>
          <a data-id="aid_organizations_clear" href="/organizations/clear">
            {__('Any Organizations')}
          </a>
        </li>
        <li>
          <a
            className="manage-menu"
            data-id="aid_organizations"
            href="/organizations"
          >
            {__('Manage Organizations')}
          </a>
        </li>
        <li className="divider" />
        {organizations.map((organization, i) => (
          <li key={i}>
            <a
              className="manage-menu"
              data-id={`aid_organizations_${organization.title}`}
              onClick={() => {
                onOrgClick(organization.id, organization.title);
                window.Turbolinks.visit(organization.href);
              }}
            >
              {organization.title}
            </a>
          </li>
        ))}
      </ul>
    </NavItem> }
    {taxonomiesBool.locations &&
    <NavItem className="dropdown org-switcher" id="location-dropdown">
      <a
        href="#"
        className="dropdown-toggle nav-item-iconic"
        data-toggle="dropdown"
      >
        {currentLocation}
        <span className="caret" />
      </a>
      <ul className="dropdown-menu">
        <li className="dropdown-header">{__('Location')}</li>
        <li>
          <a data-id="aid_locations_clear" href="/locations/clear">
            {__('Any Location')}
          </a>
        </li>
        <li>
          <a className="manage-menu" data-id="aid_locations" href="/locations">
            {__('Manage Locations')}
          </a>
        </li>
        <li className="divider" />
        {locations.map((location, i) => (
          <li key={i}>
            <a
              className="manage-menu"
              data-id={`aid_locations_${location.title}`}
              onClick={() => {
                onLocationClick(location.id, location.title);
                window.Turbolinks.visit(location.href);
              }}
            >
              {location.title}
            </a>
          </li>
        ))}
      </ul>
      </NavItem> }
    {isLoading && (
      <NavItem id="vertical-spinner">
        <Spinner size="md" inverse loading />
      </NavItem>
    )}
  </Nav>
);
TaxonomySwitcher.propTypes = {
  /** Additional element css classes */
  className: PropTypes.string,
  /** Locations array */
  locations: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    title: PropTypes.string,
    href: PropTypes.string,
  })),
  /** Organizations array */
  organizations: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    title: PropTypes.string,
    href: PropTypes.string,
  })),
  /** isLoading Prop */
  isLoading: PropTypes.bool,
  /** current Organization */
  currentOrganization: PropTypes.string,
  /** current Location */
  currentLocation: PropTypes.string,
};
TaxonomySwitcher.defaultProps = {
  className: '',
  locations: [],
  organizations: [],
  isLoading: false,
  currentLocation: '',
  currentOrganization: '',
};
export default TaxonomySwitcher;
