import PropTypes from 'prop-types';
import React from 'react';
import {
  ClipboardCopy,
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
  Divider,
} from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';
import CardTemplate from '../../../../Templates/CardItem/CardTemplate';
import Slot from '../../../../../common/Slot';
import SkeletonLoader from '../../../../../common/SkeletonLoader';
import DefaultLoaderEmptyState from '../../../../DetailsCard/DefaultLoaderEmptyState';
import LongDateTime from '../../../../../common/dates/LongDateTime';
import { STATUS } from '../../../../../../constants';
import RelativeDateTime from '../../../../../common/dates/RelativeDateTime';

const SystemPropertiesCard = ({ status, isExpandedGlobal, hostDetails }) => {
  const {
    name,
    uuid,
    model_name: model,
    location_name: location,
    organization_name: organization,
    owner_name: ownerName,
    domain_name: domain,
    hostgroup_name: hostgroupName,
    owner_type: ownerType,
    created_at: createdAt,
    updated_at: updateAt,
    reported_data: { boot_time: bootTime } = {},
  } = hostDetails;
  return (
    <CardTemplate
      overrideGridProps={{ rowSpan: 2 }}
      header={__('System properties')}
      expandable
      isExpandedGlobal={isExpandedGlobal}
    >
      <DescriptionList isCompact>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Name')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {name && (
                <ClipboardCopy
                  isBlock
                  variant="inline-compact"
                  hoverTip={__('Copy to clipboard')}
                  clickTip={__('Copied to clipboard')}
                >
                  {name}
                </ClipboardCopy>
              )}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Domain')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {domain && (
                <ClipboardCopy isBlock variant="inline-compact">
                  {domain}
                </ClipboardCopy>
              )}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('UUID')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {uuid && (
                <ClipboardCopy isBlock variant="inline-compact">
                  {uuid}
                </ClipboardCopy>
              )}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <Slot
          id="host-details-tab-properties-1"
          multi
          hostDetails={hostDetails}
        />
      </DescriptionList>
      <Divider className="padded-divider" />
      <DescriptionList
        isCompact
        columnModifier={{
          default: '2Col',
        }}
      >
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Model')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {model}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Host group')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {hostgroupName}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <Slot
          id="host-details-tab-properties-2"
          multi
          hostDetails={hostDetails}
        />
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Owner')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {ownerName}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Owner type')}</DescriptionListTerm>
          <DescriptionListDescription>{ownerType}</DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Location')}</DescriptionListTerm>
          <DescriptionListDescription>{location}</DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Organization')}</DescriptionListTerm>
          <DescriptionListDescription>
            {organization}
          </DescriptionListDescription>
        </DescriptionListGroup>
      </DescriptionList>
      <Divider className="padded-divider" />
      <DescriptionList isCompact>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Created at')}</DescriptionListTerm>
          <DescriptionListDescription>
            {createdAt && <LongDateTime date={createdAt} />}
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Updated at')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {updateAt && <LongDateTime date={updateAt} />}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Boot time')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {bootTime && <RelativeDateTime date={bootTime} />}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
      </DescriptionList>
    </CardTemplate>
  );
};

SystemPropertiesCard.propTypes = {
  status: PropTypes.string,
  isExpandedGlobal: PropTypes.bool,
  hostDetails: PropTypes.shape({
    hostgroup_name: PropTypes.string,
    model_name: PropTypes.string,
    organization_name: PropTypes.string,
    location_name: PropTypes.string,
    owner_name: PropTypes.string,
    owner_type: PropTypes.string,
    name: PropTypes.string,
    uuid: PropTypes.string,
    domain_name: PropTypes.string,
    created_at: PropTypes.string,
    updated_at: PropTypes.string,
    reported_data: PropTypes.object,
  }),
};

SystemPropertiesCard.defaultProps = {
  status: STATUS.PENDING,
  isExpandedGlobal: false,
  hostDetails: {
    name: undefined,
    model_name: undefined,
    organization_name: undefined,
    location_name: undefined,
    hostgroup_name: undefined,
    owner_type: undefined,
    owner_name: undefined,
    uuid: undefined,
    domain_name: undefined,
    created_at: undefined,
    updated_at: undefined,
    reported_data: { boot_time: undefined },
  },
};

export default SystemPropertiesCard;
