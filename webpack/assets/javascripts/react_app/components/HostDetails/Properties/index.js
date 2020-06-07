import React from 'react';
import styles from '@patternfly/react-styles/css/components/DataList/data-list';
import {
  DataList,
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  DataListCell,
} from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';

const Properties = ({ hostData }) => {
  return (
    <DataList aria-label="Host Properties" className={styles.modifiers.compact}>
      <DataListItem>
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell key="os">
                <span> {__('Operating System')}</span>
              </DataListCell>,
              <DataListCell key="os-content">
                <img
                  height="16"
                  width="16"
                  alt="os logo"
                  src={hostData.operatingsystem_icon}
                />{' '}
                {hostData.operatingsystem_name}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem>
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled key="domain">
                <span>{__('Domain')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="domain-content">
                {hostData.domain_name}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem>
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="architecture">
                <span id="simple-item2">{__('Architecture')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="architecture-content">
                {hostData.architecture_name}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem>
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="ip">
                <span id="simple-item2">{__('IP Address')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="ip-content">
                {hostData.ip}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem>
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="ip6">
                <span>{__('IP6 Address')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="ip6-content">
                {hostData.ip6}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem>
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="mac">
                <span id="simple-item2">{__('MAC')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="mac-content">
                {hostData.mac}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem>
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="location">
                <span id="simple-item2">{__('Location')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="location-content">
                {hostData.location_name}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>

      <DataListItem>
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell isFilled alignRight key="org">
                <span id="simple-item2">{__('Organization')}</span>
              </DataListCell>,
              <DataListCell isFilled alignRight key="org-content">
                {hostData.organization_name}
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
    </DataList>
  );
};

export default Properties;
