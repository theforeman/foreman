import PropTypes from 'prop-types';
import React from 'react';
import { Divider, Button } from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';
import CardTemplate from '../../../../Templates/CardItem/CardTemplate';
import { STATUS } from '../../../../../../constants';
import NICDescriptionList from './NICDescriptionList';
import SkeletonLoader from '../../../../../common/SkeletonLoader';
import './NetworkingInterfaces.scss';

const NetworkingInterfacesCard = ({
  status,
  hostDetails: {
    interfaces = [],
    name,
    permissions: { edit_hosts: editPermission } = {},
  },
}) => (
  <CardTemplate header={__('Networking interfaces')} expandable masonryLayout>
    <SkeletonLoader
      skeletonProps={{ count: 3 }}
      status={status}
      emptyState={
        <p className="nic-empty-state">{__('No network interfaces')}</p>
      }
    >
      {interfaces?.length && (
        <>
          {[...interfaces]
            // eslint-disable-next-line no-nested-ternary
            ?.sort((a, b) => (a.primary ? -1 : b.primary ? 1 : 0))
            .map((i, index) => (
              <React.Fragment key={index}>
                <NICDescriptionList foremanInterface={i} status={status} />
                <Divider className="padded-divider" />
              </React.Fragment>
            ))}
        </>
      )}
    </SkeletonLoader>
    {editPermission && (
      <Button
        variant="link"
        component="a"
        href={`/hosts/${name}/edit#interfaces`}
      >
        {__('Edit interfaces')}
      </Button>
    )}
  </CardTemplate>
);

NetworkingInterfacesCard.propTypes = {
  status: PropTypes.string,
  hostDetails: PropTypes.shape({
    name: PropTypes.string,
    interfaces: PropTypes.array,
    permissions: PropTypes.object,
  }),
};

NetworkingInterfacesCard.defaultProps = {
  status: STATUS.PENDING,
  hostDetails: {
    interfaces: [],
    permissions: {
      edit_hosts: false,
    },
  },
};

export default NetworkingInterfacesCard;
