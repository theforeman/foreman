import PropTypes from 'prop-types';
import React from 'react';
import {
  DataList,
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  Card,
  DataListCell,
} from '@patternfly/react-core';
import SkeletonLoader from '../../common/SkeletonLoader';
import { translate as __ } from '../../../common/I18n';

const Properties = ({ hostData, isLoading }) => (
  <Card isHoverable>
    <DataList aria-label="Host Properties" isCompact>
      <DataListItem aria-labelledby="name">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell key="os">
                <span> {__('Operating System')}</span>
              </DataListCell>,
              <DataListCell key="os-content">
                {hostData.operatingsystem_name || (
                  <SkeletonLoader isLoading={isLoading} />
                )}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem aria-labelledby="domain">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled key="domain">
                <span>{__('Domain')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="domain-content">
                {hostData.domain_name || (
                  <SkeletonLoader isLoading={isLoading} />
                )}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem aria-labelledby="architecture">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="architecture">
                <span id="simple-item2">{__('Architecture')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="architecture-content">
                {hostData.architecture_name || (
                  <SkeletonLoader isLoading={isLoading} />
                )}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem aria-labelledby="ip">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="ip">
                <span id="simple-item2">{__('IP Address')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="ip-content">
                {hostData.ip || <SkeletonLoader isLoading={isLoading} />}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem aria-labelledby="ip6">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="ip6">
                <span>{__('IP6 Address')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="ip6-content">
                {hostData.ip6 || <SkeletonLoader isLoading={isLoading} />}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem aria-labelledby="mac">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="mac">
                <span id="simple-item2">{__('MAC')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="mac-content">
                {hostData.mac || <SkeletonLoader isLoading={isLoading} />}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem aria-labelledby="location">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="location">
                <span id="simple-item2">{__('Location')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="location-content">
                {hostData.location_name || (
                  <SkeletonLoader isLoading={isLoading} />
                )}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>

      <DataListItem aria-labelledby="organization">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="org">
                <span id="simple-item2">{__('Organization')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="org-content">
                {hostData.organization_name || (
                  <SkeletonLoader isLoading={isLoading} />
                )}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
    </DataList>
  </Card>
);

Properties.propTypes = {
  hostData: PropTypes.shape({
    architecture_name: PropTypes.string,
    domain_name: PropTypes.string,
    ip: PropTypes.string,
    ip6: PropTypes.string,
    location_name: PropTypes.string,
    mac: PropTypes.string,
    operatingsystem_name: PropTypes.string,
    organization_name: PropTypes.string,
  }).isRequired,
  isLoading: PropTypes.bool.isRequired,
};

export default Properties;
