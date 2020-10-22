import React from 'react';
import {
  PropertiesSidePanel,
  PropertyItem,
} from '@patternfly/react-catalog-view-extension';
import { GlobeIcon } from '@patternfly/react-icons';
import { Card } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import SkeletonLoader from '../../common/SkeletonLoader';
import { hostDataDefaultValues, hostDataProptypes } from '../HostDataProptypes';
import './styles.css';

const PropertiesList = ({ hostData, isLoading }) => (
  <Card>
    <div
      style={{
        padding: '15px',
      }}
    >
      <PropertiesSidePanel>
        <PropertyItem
          label={__('Operating System')}
          value={
            hostData.operatingsystem_name || (
              <SkeletonLoader isLoading={isLoading} />
            )
          }
        />
        <PropertyItem
          label={__('Domain')}
          value={
            hostData.domain_name || <SkeletonLoader isLoading={isLoading} />
          }
        />
        <PropertyItem
          label={__('Architecture')}
          value={
            hostData.architecture_name || (
              <SkeletonLoader isLoading={isLoading} />
            )
          }
        />
        <PropertyItem
          label={__('IP Address')}
          value={hostData.ip || <SkeletonLoader isLoading={isLoading} />}
        />
        <PropertyItem
          label={__('IP6 Address')}
          value={hostData.ip6 || <SkeletonLoader isLoading={isLoading} />}
        />
        <PropertyItem
          label={__('MAC')}
          value={hostData.mac || <SkeletonLoader isLoading={isLoading} />}
        />

        <PropertyItem
          label={__('Location')}
          value={
            hostData.location_name || <SkeletonLoader isLoading={isLoading} />
          }
        />
        <PropertyItem
          label={__('Organization')}
          value={
            hostData.organization_name || (
              <SkeletonLoader isLoading={isLoading} />
            )
          }
        />
      </PropertiesSidePanel>
      <PropertyItem
        label="Created At"
        value={
          <span>
            <GlobeIcon /> {hostData.created_at}
          </span>
        }
      />
    </div>
  </Card>
);

PropertiesList.propTypes = hostDataProptypes;
PropertiesList.defaultProps = hostDataDefaultValues;

export default PropertiesList;
