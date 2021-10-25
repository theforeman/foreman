import React from 'react';
import PropTypes from 'prop-types';
import {
  PageHeaderTools,
  PageHeaderToolsGroup,
  PageHeaderToolsItem,
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
import InstanceTitleViewer from './InstanceTitleViewer';
import './HeaderToolbar.scss';

const HeaderToolbar = ({
  locations,
  orgs,
  notification_url: notificationUrl,
  user,
  stop_impersonation_url: stopImpersonationUrl,
  instance_title: instanceTitle,
  isLoading,
}) => (
  <PageHeaderTools id="data-toolbar">
    <PageHeaderToolsGroup className="header-tool-item-hidden-lg">
      <TaxonomySwitcher
        locations={locations.available_locations || []}
        organizations={orgs.available_organizations || []}
        isLoading={isLoading}
      />
    </PageHeaderToolsGroup>
    <PageHeaderToolsGroup>
      <PageHeaderToolsItem>
        <InstanceTitleViewer title={instanceTitle} />
      </PageHeaderToolsItem>
      <PageHeaderToolsItem className="notifications_container">
        <NotificationContainer data={{ url: notificationUrl }} />
      </PageHeaderToolsItem>
      {user.impersonated_by && (
        <PageHeaderToolsItem className="impersonation-item">
          <ImpersonateIcon stopImpersonationUrl={stopImpersonationUrl} />
        </PageHeaderToolsItem>
      )}

      <PageHeaderToolsItem className="header-tool-item-hidden-lg user-nav-item">
        <UserDropdowns notificationUrl={notificationUrl} user={user} />
      </PageHeaderToolsItem>
    </PageHeaderToolsGroup>
  </PageHeaderTools>
);
HeaderToolbar.propTypes = {
  stop_impersonation_url: PropTypes.string.isRequired,
  instance_title: PropTypes.string,
  locations: locationPropType.isRequired,
  orgs: organizationPropType.isRequired,
  notification_url: PropTypes.string.isRequired,
  user: userPropType,
  isLoading: layoutPropTypes.isLoading,
};

HeaderToolbar.defaultProps = {
  instance_title: null,
  user: {},
  isLoading: layoutDefaultProps.isLoading,
};
export default HeaderToolbar;
