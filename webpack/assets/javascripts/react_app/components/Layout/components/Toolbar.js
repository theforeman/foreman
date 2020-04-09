import React from 'react';
import {
  DataToolbar,
  DataToolbarContent,
  DataToolbarGroup,
  DataToolbarItem,
} from '@patternfly/react-core';
import TaxonomySwitcher from './TaxonomySwitcher';
import UserDropdowns from './UserDropdowns';
import NotificationContainer from '../../notifications';
import ImpersonateIcon from './ImpersonateIcon';
import { layoutPropTypes, layoutDefaultProps } from '../LayoutHelper';

const Toolbar = ({
  data,
  currentLocation,
  changeLocation,
  currentOrganization,
  changeOrganization,
  isLoading,
  changeActiveMenu,
  ...props
}) => (
  <DataToolbar id="data-toolbar" {...props}>
    <DataToolbarContent style={{ width: '100%' }}>
      <DataToolbarGroup
        breakpointMods={[
          { modifier: 'space-items-sm' },
          { modifier: 'hidden' },
          { modifier: 'visible', breakpoint: 'xl' },
        ]}
      >
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
      </DataToolbarGroup>
      <DataToolbarGroup
        breakpointMods={[
          { modifier: 'space-items-md' },
          { modifier: 'align-right' },
          { modifier: 'hidden' },
          { modifier: 'visible', breakpoint: 'md' },
        ]}
      >
        <DataToolbarItem>
          <NotificationContainer data={{ url: data.notification_url }} />
        </DataToolbarItem>
        {data.user.impersonated_by && (
          <DataToolbarItem>
            <ImpersonateIcon
              stopImpersonationUrl={data.stop_impersonation_url}
            />
          </DataToolbarItem>
        )}
        <DataToolbarItem>
          <UserDropdowns
            notificationUrl={data.notification_url}
            user={data.user}
            changeActiveMenu={changeActiveMenu}
            stopImpersonationUrl={data.stop_impersonation_url}
          />
        </DataToolbarItem>
      </DataToolbarGroup>
    </DataToolbarContent>
  </DataToolbar>
);
Toolbar.propTypes = {
  data: layoutPropTypes.data,
  currentLocation: layoutPropTypes.currentLocation,
  changeLocation: layoutPropTypes.changeLocation,
  currentOrganization: layoutPropTypes.currentOrganization,
  changeOrganization: layoutPropTypes.changeOrganization,
  isLoading: layoutPropTypes.isLoading,
  changeActiveMenu: layoutPropTypes.changeActiveMenu,
};
Toolbar.defaultProps = {
  data: layoutDefaultProps.data,
  currentLocation: layoutDefaultProps.currentLocation,
  changeLocation: layoutDefaultProps.changeLocation,
  currentOrganization: layoutDefaultProps.currentOrganization,
  changeOrganization: layoutDefaultProps.changeOrganization,
  isLoading: layoutDefaultProps.isLoading,
  changeActiveMenu: layoutDefaultProps.changeActiveMenu,
};
export default Toolbar;
