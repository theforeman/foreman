import PropTypes from 'prop-types';
import React from 'react';
import {
  Button,
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
  Card,
  CardActions,
  CardHeader,
  CardTitle,
  CardBody,
  ClipboardCopy,
  Divider,
  Flex,
  FlexItem,
  GridItem,
} from '@patternfly/react-core';
import { PencilAltIcon, UserIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';
import SkeletonLoader from '../../common/SkeletonLoader';
import { STATUS } from '../../../constants';
import DefaultLoaderEmptyState from './DefaultLoaderEmptyState';
import PowerStatusDropDown from './PowerStatus/PowerStatusDropDown';
import { foremanUrl } from '../../../common/helpers';

import './styles.scss';

const DetailsCard = ({
  status,
  hostName,
  hostDetails: {
    ip,
    ip6,
    mac,
    comment,
    owner_id: ownerID,
    owner_name: ownerName,
    hostgroup_name: hostgroupName,
    hostgroup_id: hostgroupId,
    permissions: { power_hosts: hasPowerPermission } = {},
  },
}) => (
  <GridItem xl2={3} xl={4} md={6} lg={4} rowSpan={2}>
    <Card ouiaId="details-card">
      <CardHeader>
        <CardTitle>{__('Details')}</CardTitle>
        <CardActions>
          <PowerStatusDropDown
            hostID={hostName}
            hasPowerPermission={hasPowerPermission}
          />
        </CardActions>
      </CardHeader>
      <CardBody>
        <DescriptionList>
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
            <DescriptionListTerm>{__('MAC address')}</DescriptionListTerm>
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
                {hostgroupId && (
                  <Flex
                    justifyContent={{ default: 'justifyContentSpaceBetween' }}
                  >
                    <FlexItem>
                      <Button
                        component="a"
                        href={foremanUrl(
                          `/hosts?search=hostgroup="${hostgroupName}"`
                        )}
                        variant="link"
                        target="_blank"
                        isInline
                      >
                        {hostgroupName}
                      </Button>
                    </FlexItem>
                    <FlexItem>
                      <Button
                        component="a"
                        href={foremanUrl(
                          `/hostgroups/${hostgroupId}-${(
                            hostgroupName || ''
                          ).replace('.', '-')}/edit`
                        )}
                        variant="plain"
                        target="_blank"
                        isInline
                      >
                        <PencilAltIcon />
                      </Button>
                    </FlexItem>
                  </Flex>
                )}
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
  </GridItem>
);

DetailsCard.propTypes = {
  hostName: PropTypes.string,
  status: PropTypes.string,
  hostDetails: PropTypes.shape({
    comment: PropTypes.string,
    hostgroup_name: PropTypes.string,
    hostgroup_id: PropTypes.number,
    ip: PropTypes.string,
    ip6: PropTypes.string,
    mac: PropTypes.string,
    owner_id: PropTypes.number,
    owner_name: PropTypes.string,
    permissions: PropTypes.object,
  }),
};

DetailsCard.defaultProps = {
  hostName: undefined,
  status: STATUS.PENDING,
  hostDetails: {
    comment: undefined,
    hostgroup_name: undefined,
    hostgroup_id: undefined,
    ip: undefined,
    ip6: undefined,
    mac: undefined,
    owner_id: undefined,
    owner_name: undefined,
    permissions: { power_hosts: false },
  },
};

export default DetailsCard;
