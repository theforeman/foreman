import React from 'react';
import { VerticalNav } from 'patternfly-react';
import Taxonomies from './components/Taxonomies';
import './layout.scss';
import UserDropdowns from './components/UserDropdowns';

class Layout extends React.Component {
  componentDidMount() {
    const { data, fetchMenuItems } = this.props;
    fetchMenuItems(data);
  }

  render() {
    const {
      items,
      data,
      isLoading,
      children,
      changeActiveMenu,
      currentOrg,
      currentLoc,
      changeOrg,
      changeLoc,
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
          <Taxonomies
            locations={data.locations}
            organizations={data.organizations}
            taxonomiesBool={data.taxonomies}
            isLoading={isLoading}
            currentLoc={currentLoc}
            currentOrg={currentOrg}
            onOrgClick={changeOrg}
            onLocationClick={changeLoc}
          />
          <UserDropdowns
            notificationUrl={data.notification_url}
            user={data.user_dropdown}
          />
        </VerticalNav.Masthead>
        {children}
      </VerticalNav>
    );
  }
}

export default Layout;
