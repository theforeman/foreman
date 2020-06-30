import React from 'react';

import { VerticalNav } from 'patternfly-react';
import { translate as __ } from '../../common/I18n';

import {
  handleMenuClick,
  layoutPropTypes,
  layoutDefaultProps,
} from './LayoutHelper';
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
          instanceTitle={data.instance_title}
        />
      </VerticalNav.Masthead>
    </VerticalNav>
    <LayoutContainer isCollapsed={isCollapsed}>{children}</LayoutContainer>
  </React.Fragment>
);

Layout.propTypes = layoutPropTypes;
Layout.defaultProps = layoutDefaultProps;

export default Layout;
