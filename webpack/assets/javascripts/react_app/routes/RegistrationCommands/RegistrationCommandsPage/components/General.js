import React from 'react';
import PropTypes from 'prop-types';

import Taxonomies from './fields/Taxonomies';
import HostGroup from './fields/HostGroup';
import OperatingSystem from './fields/OperatingSystem';
import SmartProxy from './fields/SmartProxy';
import Insecure from './fields/Insecure';

const General = ({
  organizationId,
  organizations,
  handleOrganization,
  locationId,
  locations,
  handleLocation,
  hostGroupId,
  hostGroups,
  handleHostGroup,
  operatingSystemId,
  operatingSystems,
  operatingSystemTemplate,
  handleOperatingSystem,
  smartProxyId,
  smartProxies,
  handleSmartProxy,
  insecure,
  handleInsecure,
  handleInvalidField,
  isLoading,
}) => (
  <>
    <Taxonomies
      organizationId={organizationId}
      organizations={organizations}
      handleOrganization={handleOrganization}
      locationId={locationId}
      locations={locations}
      handleLocation={handleLocation}
      isLoading={isLoading}
    />

    <HostGroup
      hostGroupId={hostGroupId}
      hostGroups={hostGroups}
      handleHostGroup={handleHostGroup}
      isLoading={isLoading}
    />

    <OperatingSystem
      operatingSystemId={operatingSystemId}
      hostGroupId={hostGroupId}
      hostGroups={hostGroups}
      handleOperatingSystem={handleOperatingSystem}
      handleInvalidField={handleInvalidField}
      operatingSystems={operatingSystems}
      operatingSystemTemplate={operatingSystemTemplate}
      isLoading={isLoading}
    />

    <SmartProxy
      smartProxyId={smartProxyId}
      smartProxies={smartProxies}
      handleSmartProxy={handleSmartProxy}
      isLoading={isLoading}
    />

    <Insecure
      insecure={insecure}
      handleInsecure={handleInsecure}
      isLoading={isLoading}
    />
  </>
);

General.propTypes = {
  organizationId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  organizations: PropTypes.array,
  operatingSystems: PropTypes.array,
  smartProxies: PropTypes.array,
  locations: PropTypes.array,
  handleOrganization: PropTypes.func.isRequired,
  locationId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  handleLocation: PropTypes.func.isRequired,
  hostGroupId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  hostGroups: PropTypes.array,
  handleHostGroup: PropTypes.func.isRequired,
  operatingSystemId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  operatingSystemTemplate: PropTypes.oneOfType([
    PropTypes.object,
    PropTypes.string,
  ]),
  handleOperatingSystem: PropTypes.func.isRequired,
  smartProxyId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  handleSmartProxy: PropTypes.func.isRequired,
  insecure: PropTypes.bool.isRequired,
  handleInsecure: PropTypes.func.isRequired,
  handleInvalidField: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
};

General.defaultProps = {
  organizationId: undefined,
  locationId: undefined,
  hostGroupId: undefined,
  hostGroups: [],
  organizations: [],
  locations: [],
  operatingSystems: [],
  smartProxies: [],
  operatingSystemId: undefined,
  operatingSystemTemplate: undefined,
  smartProxyId: undefined,
};

export default General;
