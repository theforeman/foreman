import React from 'react';
import PropTypes from 'prop-types';
import {
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
} from '@patternfly/react-core';
import { number_to_human_size as NumberToHumanSize } from 'number_helpers';
import { translate as __ } from '../../../../../../common/I18n';

const VirtLibvirt = ({ vm }) => (
  <>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Name')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.name}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Machine type')}</DescriptionListTerm>
      <DescriptionListDescription>{`${vm.domain_type}/${vm.arch}`}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('VCPU(s)')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.cpus}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('UUID')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.uuid}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Memory')}</DescriptionListTerm>
      <DescriptionListDescription>
        {`${NumberToHumanSize(vm.memory_size)} (${__(
          'Maximum'
        )}: ${NumberToHumanSize(vm.max_memory_size)})`}
      </DescriptionListDescription>
    </DescriptionListGroup>
    {vm.nics.map((nic, index) => (
      <DescriptionListGroup key={`nic-${index}`}>
        <DescriptionListTerm>{__('NIC')}</DescriptionListTerm>
        <DescriptionListDescription>
          {`${nic.bridge} - ${nic.mac} (${nic.model})`}
        </DescriptionListDescription>
      </DescriptionListGroup>
    ))}
    {Object.values(vm.volumes_attributes).map((vol, index) => (
      <DescriptionListGroup key={`volume-${index}`}>
        <DescriptionListTerm>{__('Disk capacity')}</DescriptionListTerm>
        <DescriptionListDescription>{`${vol.capacity} GB`}</DescriptionListDescription>
        <DescriptionListTerm>{__('Storage pool')}</DescriptionListTerm>
        <DescriptionListDescription>{vol.pool_name}</DescriptionListDescription>
        <DescriptionListTerm>{__('Disk allocation')}</DescriptionListTerm>
        <DescriptionListDescription>{`${vol.allocation} GB`}</DescriptionListDescription>
        <DescriptionListTerm>{__('Disk path')}</DescriptionListTerm>
        <DescriptionListDescription>{vol.path}</DescriptionListDescription>
      </DescriptionListGroup>
    ))}
  </>
);

VirtLibvirt.propTypes = {
  vm: PropTypes.object,
};

VirtLibvirt.defaultProps = {
  vm: undefined,
};

export default VirtLibvirt;
