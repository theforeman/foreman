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
  CardActions,
  ClipboardCopy,
  Divider,
} from '@patternfly/react-core';
import { UserIcon } from '@patternfly/react-icons';
import { foremanUrl } from '../../../common/helpers';
import PowerStatusDropdown from './PowerStatusDropdown';
import { translate as __ } from '../../../common/I18n';
import SkeletonLoader from '../../common/SkeletonLoader';
import { STATUS } from '../../../constants';

const DetailsCard = ({
  id: hostID,
  ip,
  ip6,
  mac,
  comment,
  owner_id: ownerID,
  owner_name: ownerName,
  hostgroup_name: hostgroupName,
  hostgroup_id: hostgroupID,
  permissions: { power_hosts: canUsePower },
  status,
}) => (
  <Card isHoverable>
    <CardHeader>
      <CardTitle>{__('Details')}</CardTitle>
      <CardActions>
        <PowerStatusDropdown hostID={hostID} hasPowerPermission={canUsePower} />
      </CardActions>
    </CardHeader>
    <CardBody>
      <DescriptionList
        isAutoColumnWidths
        columnModifier={{
          default: '2Col',
        }}
      >
        <DescriptionListGroup>
          <DescriptionListTerm>
            {ip6 ? __('IP6 Address') : __('IP Address')}
          </DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader status={status}>
              <ClipboardCopy variant="inline-compact">
                {ip6 || ip}
              </ClipboardCopy>
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Mac Address')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader status={status}>
              {mac && (
                <ClipboardCopy variant="inline-compact">{mac}</ClipboardCopy>
              )}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Host Group')}</DescriptionListTerm>
          <DescriptionListDescription>
            {' '}
            <SkeletonLoader status={status}>
              {hostgroupID && (
                <a href={foremanUrl(`/hostgroups/${hostgroupID}/edit`)}>
                  {hostgroupName}
                </a>
              )}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Host Owner')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader status={status}>
              {ownerID && (
                <a href={foremanUrl(`/users/${ownerID}/edit`)}>
                  <span>
                    <UserIcon /> {ownerName}
                  </span>
                </a>
              )}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
      </DescriptionList>
      <Divider style={{ padding: '5px' }} />
      <DescriptionList>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Comment')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader status={status}>{comment}</SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
      </DescriptionList>
    </CardBody>
  </Card>
);

DetailsCard.propTypes = {
  comment: PropTypes.string,
  hostgroup_id: PropTypes.number,
  hostgroup_name: PropTypes.string,
  id: PropTypes.number,
  ip: PropTypes.string,
  ip6: PropTypes.string,
  mac: PropTypes.string,
  owner_id: PropTypes.number,
  owner_name: PropTypes.string,
  permissions: PropTypes.object,
  status: PropTypes.string,
};

DetailsCard.defaultProps = {
  status: STATUS.PENDING,
  permissions: {},
  comment: undefined,
  hostgroup_id: undefined,
  hostgroup_name: undefined,
  ip: undefined,
  ip6: undefined,
  mac: undefined,
  owner_id: undefined,
  owner_name: undefined,
  id: undefined,
};

export default DetailsCard;
