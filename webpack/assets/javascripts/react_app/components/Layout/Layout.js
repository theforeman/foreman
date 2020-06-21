import React from 'react';
import PropTypes from 'prop-types';

import { VerticalNav } from 'patternfly-react';
import { translate as __ } from '../../common/I18n';
import { noop } from '../../common/helpers';

import { ANY_ORGANIZATION_TEXT, ANY_LOCATION_TEXT } from './LayoutConstants';
import { handleMenuClick } from './LayoutHelper';
import LayoutContainer from './components/LayoutContainer';
import TaxonomySwitcher from './components/TaxonomySwitcher';
import UserDropdowns from './components/UserDropdowns';
import './layout.scss';

const Layout = ({
  items,
  data,
  isLoading,
  isCollapsed,
  navigate,
  expandLayoutMenus,
  collapseLayoutMenus,
  changeActiveMenu,
  changeOrganization,
  changeLocation,
  currentOrganization,
  currentLocation,
  activeMenu,
  children,
}) => (
  <React.Fragment>
    <VerticalNav
      hoverDelay={100}
      items={items}
      onItemClick={primary =>
        handleMenuClick(primary, activeMenu, changeActiveMenu)
      }
      onNavigate={({ href }) => navigate(href)}
      activePath={`/${__(activeMenu || 'active')}/`}
      onCollapse={collapseLayoutMenus}
      onExpand={expandLayoutMenus}
    >
      <VerticalNav.Masthead>
        <VerticalNav.Brand
          title={data.brand}
          iconImg={data.logo}
          href={data.root}
        />
        <TaxonomySwitcher
          taxonomiesBool={data.taxonomies}
          currentLocation={currentLocation}
          locations={
            data.taxonomies.locations ? data.locations.available_locations : []
          }
          onLocationClick={changeLocation}
          currentOrganization={currentOrganization}
          organizations={
            data.taxonomies.organizations
              ? data.orgs.available_organizations
              : []
          }
          onOrgClick={changeOrganization}
          isLoading={isLoading}
        />
        <UserDropdowns
          notificationUrl={data.notification_url}
          user={data.user}
          changeActiveMenu={changeActiveMenu}
          stopImpersonationUrl={data.stop_impersonation_url}
        />
      </VerticalNav.Masthead>
    </VerticalNav>
    <LayoutContainer isCollapsed={isCollapsed}>{children}</LayoutContainer>
  </React.Fragment>
);

Layout.propTypes = {
  children: PropTypes.node,
  currentOrganization: PropTypes.string,
  currentLocation: PropTypes.string,
  isLoading: PropTypes.bool,
  isCollapsed: PropTypes.bool,
  activeMenu: PropTypes.string,
  navigate: PropTypes.func,
  changeActiveMenu: PropTypes.func,
  changeOrganization: PropTypes.func,
  changeLocation: PropTypes.func,
  expandLayoutMenus: PropTypes.func,
  collapseLayoutMenus: PropTypes.func,
  items: PropTypes.arrayOf(
    PropTypes.shape({
      title: PropTypes.string.isRequired,
      className: PropTypes.string,
      iconClass: PropTypes.string.isRequired,
      initialActive: PropTypes.bool,
      subItems: PropTypes.arrayOf(
        PropTypes.shape({
          title: PropTypes.string,
          isDivider: PropTypes.bool,
          className: PropTypes.string,
          href: PropTypes.string,
        })
      ),
    })
  ),
  data: PropTypes.shape({
    brand: PropTypes.string,
    stop_impersonation_url: PropTypes.string.isRequired,
    menu: PropTypes.arrayOf(
      PropTypes.shape({
        type: PropTypes.string.isRequired,
        name: PropTypes.string.isRequired,
        icon: PropTypes.string.isRequired,
        children: PropTypes.any,
      })
    ),
    locations: PropTypes.shape({
      current_location: PropTypes.string,
      available_locations: PropTypes.arrayOf(
        PropTypes.shape({
          href: PropTypes.string.isRequired,
          id: PropTypes.number.isRequired,
          title: PropTypes.string,
        })
      ),
    }),
    orgs: PropTypes.shape({
      current_org: PropTypes.string,
      available_organizations: PropTypes.arrayOf(
        PropTypes.shape({
          href: PropTypes.string.isRequired,
          id: PropTypes.number.isRequired,
          title: PropTypes.string,
        })
      ),
    }),
    root: PropTypes.string.isRequired,
    logo: PropTypes.string.isRequired,
    notification_url: PropTypes.string.isRequired,
    taxonomies: PropTypes.shape({
      locations: PropTypes.bool.isRequired,
      organizations: PropTypes.bool.isRequired,
    }),
    user: PropTypes.shape({
      current_user: PropTypes.object.isRequired,
      user_dropdown: PropTypes.arrayOf(
        PropTypes.shape({
          children: PropTypes.any,
          icon: PropTypes.string.isRequired,
          name: PropTypes.string.isRequired,
          type: PropTypes.string.isRequired,
        })
      ),
    }),
  }),
};

Layout.defaultProps = {
  children: null,
  items: [],
  data: {},
  currentOrganization: ANY_ORGANIZATION_TEXT,
  currentLocation: ANY_LOCATION_TEXT,
  isLoading: false,
  isCollapsed: false,
  activeMenu: '',
  navigate: noop,
  changeActiveMenu: noop,
  changeOrganization: noop,
  changeLocation: noop,
  expandLayoutMenus: noop,
  collapseLayoutMenus: noop,
};

export default Layout;
