import React from 'react';
import { VerticalNav } from 'patternfly-react';
import TaxonomySwitcher from './components/TaxonomySwitcher';
import './layout.scss';
import UserDropdowns from './components/UserDropdowns';

class Layout extends React.Component {
  componentDidMount() {
    const { items, data, fetchMenuItems } = this.props;
    if (items.length === 0) fetchMenuItems(data);
  }

  render() {
    const {
      items,
      data,
      isLoading,
      children,
      changeActiveMenu,
      currentOrganization,
      currentLocation,
      changeOrganization,
      changeLocation,
    } = this.props;
    return (
      <VerticalNav
        hoverDelay={0}
        items={items}
        onItemClick={changeActiveMenu}
        {...this.props}
      >
        <VerticalNav.Masthead>
          <VerticalNav.Brand
            title="FOREMAN"
            iconImg={data.logo}
            href={data.root}
          />
          <TaxonomySwitcher
            taxonomiesBool={data.taxonomies}
            locations={data.locations}
            organizations={data.organizations}
            currentLocation={currentLocation}
            currentOrganization={currentOrganization}
            onOrgClick={changeOrganization}
            onLocationClick={changeLocation}
            isLoading={isLoading}
          />
          <UserDropdowns
            notificationUrl={data.notification_url}
            userDropdown={data.user_dropdown}
            user={data.user}
          />
        </VerticalNav.Masthead>
        {children}
      </VerticalNav>
    );
  }
}

export default Layout;
