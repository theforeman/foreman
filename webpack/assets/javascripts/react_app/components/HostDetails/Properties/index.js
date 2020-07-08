import PropTypes from 'prop-types';
import React from 'react';
import Skeleton from 'react-loading-skeleton';

// eslint-disable-next-line import/no-extraneous-dependencies
import styles from '@patternfly/react-styles/css/components/DataList/data-list';
import {
  DataList,
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  Card,
  DataListCell,
} from '@patternfly/react-core';
import OSIcon from './OSIcon';
import { translate as __ } from '../../../common/I18n';

const Properties = ({ hostData }) => (
  <Card isHoverable>
    <DataList aria-label="Host Properties" className={styles.modifiers.compact}>
      <DataListItem aria-labelledby="name">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell key="os">
                <span> {__('Operating System')}</span>
              </DataListCell>,
              <DataListCell key="os-content">
                <OSIcon
                  os={hostData.operatingsystem_name}
                  family={hostData.family}
                />{' '}
                {hostData.operatingsystem_name || <Skeleton />}
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
                {hostData.domain_name || <Skeleton />}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem aria-labelledby="architecutre">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="architecture">
                <span id="simple-item2">{__('Architecture')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="architecture-content">
                {hostData.architecture_name || <Skeleton />}
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
                {hostData.ip || <Skeleton />}
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
                {hostData.ip6 || <Skeleton />}
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
                {hostData.mac || <Skeleton />}
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
                {hostData.location_name || <Skeleton />}
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
                {hostData.organization_name || <Skeleton />}
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
    name: PropTypes.string,
    family: PropTypes.string,
    architecture_name: PropTypes.string,
    domain_name: PropTypes.string,
    ip: PropTypes.string,
    ip6: PropTypes.string,
    location_name: PropTypes.string,
    mac: PropTypes.string,
    operatingsystem_icon: PropTypes.string,
    operatingsystem_name: PropTypes.string,
    organization_name: PropTypes.string,
  }).isRequired,
};

export default Properties;
