import PropTypes from 'prop-types';
import React from 'react';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
  Card,
  CardHeader,
  CardTitle,
  CardBody,
  ClipboardCopy,
  Divider,
} from '@patternfly/react-core';
import { UserIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';
import SkeletonLoader from '../../common/SkeletonLoader';
import { STATUS } from '../../../constants';
import DefaultLoaderEmptyState from './DefaultLoaderEmptyState';

import './styles.scss';

const DetailsCard = ({
  ip,
  ip6,
  mac,
  comment,
  owner_id: ownerID,
  owner_name: ownerName,
  hostgroup_name: hostgroupName,
  status,
}) => (
  <Card isHoverable>
    <CardHeader>
      <CardTitle>{__('Details')}</CardTitle>
    </CardHeader>
    <CardBody>
      <DescriptionList
        isAutoColumnWidths
        columnModifier={{
          default: '2Col',
        }}
      >
        <DescriptionListGroup>
          <DescriptionListTerm>{__('IPv6 address')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              emptyState={<DefaultLoaderEmptyState />}
              status={status}
            >
              {ip6 && (
                <ClipboardCopy isBlock variant="inline-compact">
                  {ip6}
                </ClipboardCopy>
              )}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('IPv4 address')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              emptyState={<DefaultLoaderEmptyState />}
              status={status}
            >
              {ip && (
                <ClipboardCopy isBlock variant="inline-compact">
                  {ip}
                </ClipboardCopy>
              )}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('MAC Address')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              emptyState={<DefaultLoaderEmptyState />}
              status={status}
            >
              {mac && (
                <ClipboardCopy isBlock variant="inline-compact">
                  {mac}
                </ClipboardCopy>
              )}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
      </DescriptionList>

      <Divider className="padded-divider" />
      <DescriptionList>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Host group')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              emptyState={<DefaultLoaderEmptyState />}
              status={status}
            >
              {hostgroupName}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Host owner')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              emptyState={<DefaultLoaderEmptyState />}
              status={status}
            >
              {ownerID && (
                <span>
                  <UserIcon /> {ownerName}
                </span>
              )}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Comment')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              emptyState={<DefaultLoaderEmptyState />}
              status={status}
            >
              {comment}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
      </DescriptionList>
    </CardBody>
  </Card>
);

DetailsCard.propTypes = {
  comment: PropTypes.string,
  hostgroup_name: PropTypes.string,
  ip: PropTypes.string,
  ip6: PropTypes.string,
  mac: PropTypes.string,
  owner_id: PropTypes.number,
  owner_name: PropTypes.string,
  status: PropTypes.string,
};

DetailsCard.defaultProps = {
  status: STATUS.PENDING,
  comment: undefined,
  hostgroup_name: undefined,
  ip: undefined,
  ip6: undefined,
  mac: undefined,
  owner_id: undefined,
  owner_name: undefined,
};

export default DetailsCard;
