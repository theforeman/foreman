import React from 'react';
import PropTypes from 'prop-types';
import {
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
} from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';

const VirtEc2 = ({ vm }) => (
  <>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Availability zone')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.availability_zone}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Public IP address')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.public_ip_address}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('DNS name')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.dns_name}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Private IP address')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.private_ip_address}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Private DNS name')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.private_dns_name}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Kernel ID')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.kernel_id}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('State')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.state}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Created')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.created_at}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Root device type')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.root_device_type}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Image ID')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.image_id}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Flavor ID')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.flavor_id}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Security Groups')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.groups}</DescriptionListDescription>
    </DescriptionListGroup>
  </>
);

VirtEc2.propTypes = {
  vm: PropTypes.object,
};

VirtEc2.defaultProps = {
  vm: undefined,
};

export default VirtEc2;
