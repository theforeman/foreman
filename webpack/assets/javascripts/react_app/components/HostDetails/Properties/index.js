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
import { STATUS } from '../../../constants';
import { translate as __ } from '../../../common/I18n';

const Properties = ({ hostData, status }) => (
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
                <SkeletonLoader status={status}>
                  {hostData.operatingsystem_name}
                </SkeletonLoader>
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
                <SkeletonLoader status={status}>
                  {hostData.domain_name}
                </SkeletonLoader>
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
                <SkeletonLoader status={status}>
                  {hostData.architecture_name}
                </SkeletonLoader>
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
                <SkeletonLoader status={status}>
                  {hostData.operatingsystem_name}
                </SkeletonLoader>
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
                <SkeletonLoader status={status}>{hostData.ip6}</SkeletonLoader>
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
                <SkeletonLoader status={status}>{hostData.mac}</SkeletonLoader>
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
                <SkeletonLoader status={status}>
                  {hostData.location_name}
                </SkeletonLoader>
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
                <SkeletonLoader status={status}>
                  {hostData.organization_name}
                </SkeletonLoader>
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
  status: PropTypes.string,
};

Properties.defaultProps = {
  status: STATUS.PENDING,
};
export default Properties;
