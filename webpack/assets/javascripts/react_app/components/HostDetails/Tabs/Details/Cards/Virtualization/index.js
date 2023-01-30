import PropTypes from 'prop-types';
import React from 'react';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
} from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';
import { foremanUrl } from '../../../../../../common/helpers';
import { useAPI } from '../../../../../../common/hooks/API/APIHooks';
import EmptyState from '../../../../../common/EmptyState';
import ErrorBoundary from '../../../../../common/ErrorBoundary';
import CardTemplate from '../../../../Templates/CardItem/CardTemplate';
import VirtVmware from './VirtVmware';
import VirtOvirt from './VirtOvirt';
import VirtLibvirt from './VirtLibvirt';
import VirtEc2 from './VirtEc2';
import VirtOpenstack from './VirtOpenstack';

const VirtualizationCard = ({ hostDetails }) => {
  const {
    id: hostId,
    compute_resource_id: computeResourceId,
    compute_resource_name: computeResourceName,
    compute_resource_provider: provider,
  } = hostDetails;
  const virtUrl = foremanUrl(`/api/hosts/${hostId}/vm_compute_attributes`);
  const { response: vm, status } = useAPI('get', virtUrl);

  if (!provider) return null;
  if (status !== 'RESOLVED') return null;

  const components = {
    vmware: VirtVmware,
    libvirt: VirtLibvirt,
    ovirt: VirtOvirt,
    ec2: VirtEc2,
    openstack: VirtOpenstack,
  };
  const VirtCardDetails = components[provider];

  const errorFallback = () => (
    <EmptyState
      icon={<div />}
      header={__('Something went wrong')}
      description={__('There was an error loading this content.')}
    />
  );

  return (
    <CardTemplate header={__('Virtualization')} expandable masonryLayout>
      <ErrorBoundary fallback={errorFallback}>
        <DescriptionList isCompact isHorizontal>
          {VirtCardDetails && <VirtCardDetails vm={vm} />}
          <DescriptionListGroup>
            <DescriptionListTerm>{__('Running on')}</DescriptionListTerm>
            <DescriptionListDescription>
              <a
                href={`/compute_resources/${computeResourceId}-${computeResourceName}`}
              >
                {computeResourceName}
              </a>
            </DescriptionListDescription>
          </DescriptionListGroup>
        </DescriptionList>
      </ErrorBoundary>
    </CardTemplate>
  );
};

VirtualizationCard.propTypes = {
  hostDetails: PropTypes.shape({
    id: PropTypes.number,
    compute_resource_id: PropTypes.number,
    compute_resource_name: PropTypes.string,
    compute_resource_provider: PropTypes.string,
  }),
};

VirtualizationCard.defaultProps = {
  hostDetails: {},
};

export default VirtualizationCard;
