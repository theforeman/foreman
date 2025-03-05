import React from 'react';
import PropTypes from 'prop-types';
import {
  Toolbar,
  ToolbarContent,
  ToolbarGroup,
  ToolbarItem,
} from '@patternfly/react-core';
import TaxonomySwitcher from '../TaxonomySwitcher/TaxonomySwitcher';
import UserDropdowns from './UserDropdowns';
import NotificationContainer from '../../../notifications';
import ImpersonateIcon from '../ImpersonateIcon';
import {
  layoutPropTypes,
  layoutDefaultProps,
  locationPropType,
  organizationPropType,
  userPropType,
} from '../../LayoutHelper';
import './HeaderToolbar.scss';

const HeaderToolbar = ({
  locations,
  orgs,
  notification_url: notificationUrl,
  user,
  stop_impersonation_url: stopImpersonationUrl,
  isLoading,
}) => (
  <Toolbar ouiaId="data-toolbar" id="data-toolbar" isFullHeight isStatic>
    <ToolbarContent>
      <ToolbarGroup className="header-tool-item-hidden-lg">
        <TaxonomySwitcher
          locations={locations.available_locations || []}
          organizations={orgs.available_organizations || []}
          isLoading={isLoading}
        />
      </ToolbarGroup>
      <ToolbarGroup align={{ default: 'alignRight' }}>
        <ToolbarItem className="notifications_container">
          <NotificationContainer data={{ url: notificationUrl }} />
        </ToolbarItem>
        {user.impersonated_by && (
          <ToolbarItem className="impersonation-item">
            <ImpersonateIcon stopImpersonationUrl={stopImpersonationUrl} />
          </ToolbarItem>
        )}

        <ToolbarItem className="header-tool-item-hidden-lg user-nav-item">
          <UserDropdowns notificationUrl={notificationUrl} user={user} />
        </ToolbarItem>
      </ToolbarGroup>
    </ToolbarContent>
  </Toolbar>
);
HeaderToolbar.propTypes = {
  stop_impersonation_url: PropTypes.string.isRequired,
  locations: locationPropType.isRequired,
  orgs: organizationPropType.isRequired,
  notification_url: PropTypes.string.isRequired,
  user: userPropType,
  isLoading: layoutPropTypes.isLoading,
};

HeaderToolbar.defaultProps = {
  user: {},
  isLoading: layoutDefaultProps.isLoading,
};
export default HeaderToolbar;
